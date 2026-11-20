import { useQuery } from "@tanstack/react-query"
import { createFileRoute } from "@tanstack/react-router"

import { getHello } from "@/lib/api"

export const Route = createFileRoute("/_home/")({
  component: RouteComponent,
})

function RouteComponent() {
  const hello = useQuery({
    queryKey: ["hello"],
    queryFn: getHello,
  })

  if (hello.isPending) {
    return <h1>Loading...</h1>
  }

  if (hello.isError) {
    return <h1>Could not reach the API: {hello.error.message}</h1>
  }

  return <h1>{hello.data.message}</h1>
}
