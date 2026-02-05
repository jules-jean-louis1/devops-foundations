<script>
    import { onMount } from "svelte";
    import { PUBLIC_BACKEND_URL } from "$env/static/public";

    const status = {
        database: false,
        backend: false,
        redis: false,
    };

    onMount(async () => {
        const dbStatus = await getDbStatus();
        const backendStatus = await getBackendStatus();
        const cacheStatus = await getCacheStatus();
    });

    async function getDbStatus() {
        status.database = false;
        const res = await fetch(PUBLIC_BACKEND_URL + "/db");
        const db = await res.json();

        if (res.ok) {
            status.database = true;
            return db;
        } else {
            throw new Error(`Couldn't fetch db status data`);
        }
    }

    async function getBackendStatus() {
        status.backend = false;
        const res = await fetch(PUBLIC_BACKEND_URL + "/health");
        const backend = await res.json();

        if (res.ok) {
            status.backend = true;
            return backend;
        } else {
            throw new Error(`No backend`);
        }
    }

    async function getCacheStatus() {
        status.redis = false;
        const res = await fetch(PUBLIC_BACKEND_URL + "/cache");
        const cache = await res.json();

        if (res.ok) {
            status.redis = true;
            return cache;
        } else {
            throw new Error("No Redis");
        }
    }
</script>

<h1>Welcome to SvelteKit</h1>
<div>
    <div>
        <p>
            Backend : {#if status.backend}
                OK
            {:else}
                Down
            {/if}
        </p>
    </div>
    <div>
        <p>
            Database : {#if status.database}
                OK
            {:else}
                Down
            {/if}
        </p>
    </div>
    <div>
        <p>
            Redis : {#if status.redis}
                OK
            {:else}
                Down
            {/if}
        </p>
    </div>
</div>
<p>
    Visit <a href="https://svelte.dev/docs/kit">svelte.dev/docs/kit</a> to read the
    documentation
</p>
