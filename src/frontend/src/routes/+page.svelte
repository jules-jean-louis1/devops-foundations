<script lang="ts">
    import { onMount } from "svelte";
    import { PUBLIC_BACKEND_URL } from "$env/static/public";
    import ContactForm from "$lib/components/ContactForm.svelte";

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

    onMount(async () => {
        await getDbStatus();
        await getBackendStatus();
        await getCacheStatus();
    });

    async function getDbStatus(): Promise<void> {
        status.database = false;
        try {
            const res = await fetch(PUBLIC_BACKEND_URL + "/db");
            if (res.ok) {
                status.database = true;
            }
        } catch (error) {
            console.error("Database status check failed:", error);
        }
    }

    async function getBackendStatus(): Promise<void> {
        status.backend = false;
        try {
            const res = await fetch(PUBLIC_BACKEND_URL + "/health");
            if (res.ok) {
                status.backend = true;
            }
        } catch (error) {
            console.error("Backend status check failed:", error);
        }
    }

    async function getCacheStatus(): Promise<void> {
        status.redis = false;
        try {
            const res = await fetch(PUBLIC_BACKEND_URL + "/cache");
            if (res.ok) {
                status.redis = true;
            }
        } catch (error) {
            console.error("Cache status check failed:", error);
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
