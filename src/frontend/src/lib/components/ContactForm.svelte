<script lang="ts">
    import { contactService } from "$lib/services/contactService";

    interface FormMessage {
        text: string;
        isSuccess: boolean;
    }

    let formMessage: FormMessage | null = null;
    let isLoading = false;

    async function handleSubmit(e: Event) {
        e.preventDefault();
        isLoading = true;
        formMessage = null;

        const form = e.target as HTMLFormElement;
        const formData = new FormData(form);

        try {
            const response = await contactService.sendMessage({
                email: formData.get("email") as string,
                name: formData.get("name") as string,
                content: formData.get("content") as string,
            });

            formMessage = {
                text: response.message || "Message envoyé avec succès!",
                isSuccess: response.success,
            };

            if (response.success) {
                form.reset();
            }

            setTimeout(() => {
                formMessage = null;
            }, 4000);
        } catch (error) {
            console.error("Erreur:", error);
            formMessage = {
                text:
                    error instanceof Error
                        ? error.message
                        : "Erreur de connexion au serveur",
                isSuccess: false,
            };
        } finally {
            isLoading = false;
        }
    }
</script>

<div class="contact-form-container">
    <h2>Contactez-nous</h2>
    <form on:submit={handleSubmit}>
        <div class="form-group">
            <label for="email">Email</label>
            <input
                id="email"
                name="email"
                type="email"
                placeholder="votre.email@exemple.com"
                required
                disabled={isLoading}
            />
        </div>

        <div class="form-group">
            <label for="name">Nom</label>
            <input
                id="name"
                name="name"
                type="text"
                placeholder="Votre nom"
                required
                disabled={isLoading}
            />
        </div>

        <div class="form-group">
            <label for="content">Message</label>
            <textarea
                id="content"
                name="content"
                rows="5"
                placeholder="Votre message ici..."
                required
                disabled={isLoading}
            ></textarea>
        </div>

        <button type="submit" disabled={isLoading}>
            {isLoading ? "Envoi en cours..." : "Envoyer"}
        </button>
    </form>

    {#if formMessage}
        <div
            class="message"
            class:success={formMessage.isSuccess}
            class:error={!formMessage.isSuccess}
        >
            {formMessage.text}
        </div>
    {/if}
</div>

<style>
    .contact-form-container {
        max-width: 500px;
        margin: 2rem 0;
        padding: 1.5rem;
        border: 1px solid #e0e0e0;
        border-radius: 8px;
        background-color: #f9f9f9;
    }

    .contact-form-container h2 {
        margin-top: 0;
        color: #333;
        font-size: 1.5rem;
        margin-bottom: 1.5rem;
    }

    .form-group {
        margin-bottom: 1.5rem;
        display: flex;
        flex-direction: column;
    }

    label {
        margin-bottom: 0.5rem;
        font-weight: 600;
        color: #555;
        font-size: 0.95rem;
    }

    input,
    textarea {
        padding: 0.75rem;
        border: 1px solid #ddd;
        border-radius: 4px;
        font-family: inherit;
        font-size: 1rem;
        transition: border-color 0.3s ease;
    }

    input:focus,
    textarea:focus {
        outline: none;
        border-color: #007bff;
        box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.1);
    }

    input:disabled,
    textarea:disabled {
        background-color: #f0f0f0;
        color: #999;
        cursor: not-allowed;
    }

    button {
        width: 100%;
        padding: 0.75rem;
        background-color: #007bff;
        color: white;
        font-weight: 600;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-size: 1rem;
        transition: background-color 0.3s ease;
    }

    button:hover:not(:disabled) {
        background-color: #0056b3;
    }

    button:disabled {
        background-color: #6c757d;
        cursor: not-allowed;
    }

    .message {
        margin-top: 1rem;
        padding: 1rem;
        border-radius: 4px;
        font-weight: 500;
        animation: slideIn 0.3s ease;
    }

    .message.success {
        background-color: #d4edda;
        color: #155724;
        border: 1px solid #c3e6cb;
    }

    .message.error {
        background-color: #f8d7da;
        color: #721c24;
        border: 1px solid #f5c6cb;
    }

    @keyframes slideIn {
        from {
            opacity: 0;
            transform: translateY(-10px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
</style>
