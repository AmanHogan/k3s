package com.amanhogan.mcpk3s.service;

import io.kubernetes.client.openapi.ApiClient;
import io.kubernetes.client.openapi.ApiException;
import io.kubernetes.client.openapi.Configuration;
import io.kubernetes.client.openapi.apis.AppsV1Api;
import io.kubernetes.client.openapi.apis.CoreV1Api;
import io.kubernetes.client.openapi.models.*;
import io.kubernetes.client.openapi.models.CoreV1EventList;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import java.security.cert.X509Certificate;
import java.util.stream.Collectors;

@Service
public class K3sClusterService {

    private final CoreV1Api coreApi;
    private final AppsV1Api appsApi;

    public K3sClusterService(
            @Value("${k3s.api-server:https://192.168.56.10:6443}") String apiServer,
            @Value("${k3s.token}") String token) throws Exception {

        // Build client directly — bypasses kubeconfig auto-detection
        SSLContext sslContext = SSLContext.getInstance("TLS");
        X509TrustManager trustAll = new X509TrustManager() {
            public X509Certificate[] getAcceptedIssuers() {
                return new X509Certificate[0];
            }

            public void checkClientTrusted(X509Certificate[] c, String a) {
            }

            public void checkServerTrusted(X509Certificate[] c, String a) {
            }
        };
        sslContext.init(null, new TrustManager[] { trustAll }, null);

        okhttp3.OkHttpClient insecureHttp = new okhttp3.OkHttpClient.Builder()
                .sslSocketFactory(sslContext.getSocketFactory(), trustAll)
                .hostnameVerifier((h, s) -> true)
                .build();

        ApiClient client = new ApiClient();
        client.setBasePath(apiServer);
        client.addDefaultHeader("Authorization", "Bearer " + token);
        client.setHttpClient(insecureHttp);

        Configuration.setDefaultApiClient(client);
        this.coreApi = new CoreV1Api(client);
        this.appsApi = new AppsV1Api(client);
    }

    // ── Nodes ─────────────────────────────────────────────────────────────────

    @Tool(description = "Get the health and status of all nodes in the k3s cluster.")
    public String getNodes() {
        try {
            V1NodeList nodes = coreApi.listNode().execute();
            return nodes.getItems().stream().map(node -> {
                String name = node.getMetadata().getName();
                String ready = node.getStatus().getConditions().stream()
                        .filter(c -> "Ready".equals(c.getType()))
                        .map(c -> c.getStatus())
                        .findFirst().orElse("Unknown");
                return name + " — Ready=" + ready;
            }).collect(Collectors.joining("\n"));
        } catch (ApiException e) {
            return "Error: " + e.getResponseBody();
        }
    }

    // ── Pods ──────────────────────────────────────────────────────────────────

    @Tool(description = "Get all pods in a namespace and their status. Use 'all' for all namespaces.")
    public String getPods(
            @ToolParam(description = "Kubernetes namespace, or 'all' for every namespace") String namespace) {
        try {
            V1PodList pods = "all".equals(namespace)
                    ? coreApi.listPodForAllNamespaces().execute()
                    : coreApi.listNamespacedPod(namespace).execute();
            return pods.getItems().stream().map(pod -> {
                String ns = pod.getMetadata().getNamespace();
                String name = pod.getMetadata().getName();
                String phase = pod.getStatus() != null ? pod.getStatus().getPhase() : "Unknown";
                return "[" + ns + "] " + name + " — " + phase;
            }).collect(Collectors.joining("\n"));
        } catch (ApiException e) {
            return "Error: " + e.getResponseBody();
        }
    }

    // ── Services ──────────────────────────────────────────────────────────────

    @Tool(description = "Get all services and their external IPs in a namespace. Use 'all' for all namespaces.")
    public String getServices(
            @ToolParam(description = "Kubernetes namespace, or 'all' for every namespace") String namespace) {
        try {
            V1ServiceList svcs = "all".equals(namespace)
                    ? coreApi.listServiceForAllNamespaces().execute()
                    : coreApi.listNamespacedService(namespace).execute();
            return svcs.getItems().stream().map(svc -> {
                String ns = svc.getMetadata().getNamespace();
                String name = svc.getMetadata().getName();
                String type = svc.getSpec().getType();
                String ip = (svc.getStatus().getLoadBalancer() != null
                        && svc.getStatus().getLoadBalancer().getIngress() != null
                        && !svc.getStatus().getLoadBalancer().getIngress().isEmpty())
                                ? svc.getStatus().getLoadBalancer().getIngress().get(0).getIp()
                                : "—";
                return "[" + ns + "] " + name + " (" + type + ") → " + ip;
            }).collect(Collectors.joining("\n"));
        } catch (ApiException e) {
            return "Error: " + e.getResponseBody();
        }
    }

    // ── Deployments ───────────────────────────────────────────────────────────

    @Tool(description = "Get all deployments and their replica status in a namespace. Use 'all' for all namespaces.")
    public String getDeployments(
            @ToolParam(description = "Kubernetes namespace, or 'all' for every namespace") String namespace) {
        try {
            V1DeploymentList depls = "all".equals(namespace)
                    ? appsApi.listDeploymentForAllNamespaces().execute()
                    : appsApi.listNamespacedDeployment(namespace).execute();
            return depls.getItems().stream().map(d -> {
                String ns = d.getMetadata().getNamespace();
                String name = d.getMetadata().getName();
                Integer desired = d.getSpec().getReplicas();
                Integer ready = d.getStatus().getReadyReplicas();
                return "[" + ns + "] " + name + " — " + ready + "/" + desired + " ready";
            }).collect(Collectors.joining("\n"));
        } catch (ApiException e) {
            return "Error: " + e.getResponseBody();
        }
    }

    // ── Events ────────────────────────────────────────────────────────────────

    @Tool(description = "Get recent warning events in a namespace. Useful for diagnosing pod crashes or failures.")
    public String getWarningEvents(
            @ToolParam(description = "Kubernetes namespace, or 'all' for every namespace") String namespace) {
        try {
            CoreV1EventList events = "all".equals(namespace)
                    ? coreApi.listEventForAllNamespaces().execute()
                    : coreApi.listNamespacedEvent(namespace).execute();
            return events.getItems().stream()
                    .filter(e -> "Warning".equals(e.getType()))
                    .map(e -> "[" + e.getInvolvedObject().getName() + "] "
                            + e.getReason() + ": " + e.getMessage())
                    .collect(Collectors.joining("\n"));
        } catch (ApiException e) {
            return "Error: " + e.getResponseBody();
        }
    }

    // ── Logs ──────────────────────────────────────────────────────────────────

    @Tool(description = "Get the last 50 lines of logs from a pod.")
    public String getPodLogs(
            @ToolParam(description = "Name of the pod") String podName,
            @ToolParam(description = "Namespace the pod is in") String namespace) {
        try {
            return coreApi.readNamespacedPodLog(podName, namespace)
                    .tailLines(50)
                    .execute();
        } catch (ApiException e) {
            return "Error: " + e.getResponseBody();
        }
    }
}
