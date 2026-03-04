<script lang="ts">
    import { onMount } from "svelte";
    import ContactForm from "$lib/components/ContactForm.svelte";
    import { apiService } from "$lib/services/apiService";

    interface StatusType {
        database: boolean;
        backend: boolean;
        redis: boolean;
    }

    let status: StatusType = {
        database: false,
        backend: false,
        redis: false,
    };

    let visitorCount = 0;

    onMount(async () => {
        await getDbStatus();
        await getBackendStatus();
        await getCacheStatus();
        await getVisitor();
    });
    
    async function getDbStatus(): Promise<void> {
        status.database = false;
        try {
            const res = await apiService.getDbStatus();
            if (res.status === "connected") {
                status.database = true;
            }
        } catch (error: any) {
            console.error("Database status check failed:", error.message);
        }
    }

    async function getBackendStatus(): Promise<void> {
        status.backend = false;
        try {
            const res = await apiService.getBackendHealth();
            status.backend = true;
        } catch (error: any) {
            console.error("Backend status check failed:", error.message);
        }
    }

    async function getCacheStatus(): Promise<void> {
        status.redis = false;
        try {
            const res = await apiService.getCacheStatus();
            if (res.status === "connected") {
                status.redis = true;
            }
        } catch (error: any) {
            console.error("Cache status check failed:", error.message);
        }
    }

    async function getVisitor(): Promise<void> {
        try {
            const res = await apiService.getVisitorCount();
            visitorCount = res;

        } catch (error: any) {
            throw new Error("Visitor count failed: " + error.message);
        }
    }
</script>

<main>
    <h1>CloudNative Labs - Dashboard</h1>

    <section class="status-section">
        <h2>Service Status</h2>
        <div class="status-grid">
            <div class="status-item">
                <p>
                    Backend: <span class={status.backend ? "ok" : "down"}>
                        {status.backend ? "✓ OK" : "✗ Down"}
                    </span>
                </p>
            </div>
            <div class="status-item">
                <p>
                    Database: <span class={status.database ? "ok" : "down"}>
                        {status.database ? "✓ OK" : "✗ Down"}
                    </span>
                </p>
            </div>
            <div class="status-item">
                <p>
                    Redis: <span class={status.redis ? "ok" : "down"}>
                        {status.redis ? "✓ OK" : "✗ Down"}
                    </span>
                </p>
            </div>
            <div class="status-item">
                <p>
                    Visitors: <span> {visitorCount} </span>
                </p>
            </div>
        </div>
    </section>

    <section class="contact-section">
        <ContactForm />
    </section>

    <section class="docs-section">
        <p>
            Visit <a href="https://svelte.dev/docs/kit">svelte.dev/docs/kit</a> to
            read the documentation
        </p>
    </section>
</main>

<style>
    main {
        max-width: 1200px;
        margin: 0 auto;
        padding: 2rem;
    }

    h1 {
        color: #333;
        margin-bottom: 2rem;
    }

    .status-section {
        margin-bottom: 3rem;
    }

    .status-section h2 {
        color: #555;
        font-size: 1.3rem;
        margin-bottom: 1.5rem;
    }

    .status-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 1rem;
    }

    .status-item {
        padding: 1rem;
        border: 1px solid #e0e0e0;
        border-radius: 4px;
        background-color: #f9f9f9;
    }

    .status-item p {
        margin: 0;
        font-size: 1rem;
        color: #333;
    }

    .ok {
        color: #28a745;
        font-weight: 600;
    }

    .down {
        color: #dc3545;
        font-weight: 600;
    }

    .contact-section {
        margin-bottom: 3rem;
        padding: 2rem 0;
        border-top: 1px solid #e0e0e0;
        border-bottom: 1px solid #e0e0e0;
    }

    .docs-section {
        margin-top: 2rem;
        padding-top: 2rem;
        border-top: 1px solid #e0e0e0;
    }

    a {
        color: #0066cc;
        text-decoration: none;
    }

    a:hover {
        text-decoration: underline;
    }
</style>
