import { json, error } from "@sveltejs/kit";

const BACKEND_URL = "http://backend:3002";

export async function GET() {
  try {
    const response = await fetch(`${BACKEND_URL}/db`);
    if (!response.ok) {
      return error(response.status, "Database check failed");
    }
    const data = await response.json();
    return json(data);
  } catch (err) {
    return error(500, "Failed to reach backend");
  }
}
