import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    // Proxy /api calls to Spring Boot when running `npm run dev` locally
    proxy: {
      '/api': 'http://localhost:8080'
    }
  }
})
