package com.amanhogan.mcpk3s.controller;

import com.amanhogan.mcpk3s.service.K3sClusterService;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Arrays;
import java.util.List;

@RestController
@RequestMapping("/api")
@CrossOrigin
public class ClusterController {

    private final K3sClusterService service;

    public ClusterController(K3sClusterService service) {
        this.service = service;
    }

    @GetMapping("/nodes")
    public List<String> nodes() {
        return lines(service.getNodes());
    }

    @GetMapping("/pods/{namespace}")
    public List<String> pods(@PathVariable String namespace) {
        return lines(service.getPods(namespace));
    }

    @GetMapping("/services/{namespace}")
    public List<String> services(@PathVariable String namespace) {
        return lines(service.getServices(namespace));
    }

    @GetMapping("/deployments/{namespace}")
    public List<String> deployments(@PathVariable String namespace) {
        return lines(service.getDeployments(namespace));
    }

    @GetMapping("/events/{namespace}")
    public List<String> events(@PathVariable String namespace) {
        return lines(service.getWarningEvents(namespace));
    }

    @GetMapping("/logs/{namespace}/{pod}")
    public String logs(@PathVariable String namespace, @PathVariable String pod) {
        return service.getPodLogs(pod, namespace);
    }

    private List<String> lines(String text) {
        if (text == null || text.isBlank())
            return List.of();
        return Arrays.asList(text.split("\n"));
    }
}
