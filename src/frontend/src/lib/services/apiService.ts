export const apiService = {
    async getVisitorCount(): Promise<number> {
        const response = await fetch("/api/visits");
        if (!response.ok) {
            throw new Error("Failed to fetch visitor count");
        }
        const data = await response.json();
        return data.visits;
    },
    async getDbStatus(): Promise<{ status: string; data?: any; error?: string }> {
        const response = await fetch("/api/db");
        if (!response.ok) {
            const errorData = await response.json();
            return { status: "disconnected", error: errorData.error };
        }
        const data = await response.json();
        return { status: "connected", data: data.data };
    },
    async getCacheStatus(): Promise<{ status: string; message?: string; error?: string }> {
        const response = await fetch("/api/cache");
        if (!response.ok) {
            const errorData = await response.json();
            return { status: "disconnected", error: errorData.error };
        }
        const data = await response.json();
        return { status: "connected", message: data.message };
    },
    async getBackendHealth(): Promise<{ uptime: number; message: string; timestamp: number }> {
        const response = await fetch("/api/health");
        if (!response.ok) {
            throw new Error("Failed to fetch backend health");
        }
        return response.json();
    },
};