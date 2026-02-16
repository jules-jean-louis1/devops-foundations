import { json, error } from "@sveltejs/kit";
import type { RequestHandler } from "@sveltejs/kit";

const BACKEND_URL = process.env.PUBLIC_BACKEND_URL || "http://localhost:3002";

export const POST: RequestHandler = async ({ request }) => {
  try {
    // Validation des données
    const body = await request.json();
    const { sender, subject, content } = body;

    if (!sender || !subject || !content) {
      return error(400, "Tous les champs sont requis");
    }

    // Requête vers ton backend
    const response = await fetch(`${BACKEND_URL}/contact`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ sender, subject, content }),
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      return error(response.status, errorData.message || "Erreur du backend");
    }

    const data = await response.json();
    return json({
      success: true,
      message: "Message envoyé avec succès!",
      data,
    });
  } catch (err) {
    console.error("Erreur API contact:", err);
    return error(500, "Erreur serveur");
  }
};
