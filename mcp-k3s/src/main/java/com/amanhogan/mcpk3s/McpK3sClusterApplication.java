package com.amanhogan.mcpk3s;

import com.amanhogan.mcpk3s.service.K3sClusterService;
import org.springframework.ai.tool.ToolCallbackProvider;
import org.springframework.ai.tool.method.MethodToolCallbackProvider;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class McpK3sClusterApplication {

    public static void main(String[] args) {
        SpringApplication.run(McpK3sClusterApplication.class, args);
    }

    @Bean
    public ToolCallbackProvider tools(K3sClusterService k3sClusterService) {
        return MethodToolCallbackProvider.builder()
                .toolObjects(k3sClusterService)
                .build();
    }
}
