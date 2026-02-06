import { PUBLIC_BACKEND_URL } from "$env/static/public";

interface ContactFormData {
  email: string;
  name: string;
  content: string;
}

interface ApiResponse<T = unknown> {
  success: boolean;
  message: string;
  data?: T;
}

export const contactService = {
  async sendMessage(formData: ContactFormData): Promise<ApiResponse> {
    const response = await fetch(PUBLIC_BACKEND_URL + "/contact", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(formData),
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message || "Erreur lors de l'envoi");
    }

    return response.json();
  },
};
