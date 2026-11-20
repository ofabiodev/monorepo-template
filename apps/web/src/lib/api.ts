import { env } from "@/lib/env"

export type HelloResponse = {
  message: string
}

export async function getHello(): Promise<HelloResponse> {
  const response = await fetch(`${env.VITE_API_URL}/hello`)

  if (!response.ok) {
    throw new Error(`GET /hello failed with status ${response.status}`)
  }

  return (await response.json()) as HelloResponse
}
