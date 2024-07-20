module Sheets = Sheets
module Types = Types
module Node = Node

@val @scope(("process", "env"))
external port: option<string> = "PORT"

let staticRoot = Dict.get(Node.Process.env, "STATIC_ROOT")
type staticOption = {root: string}
type createOption = {logger: bool}
type cors
@module("@fastify/cors") external cors: cors = "default"

module Fastify = {
  type t
  type request

  module Reply = {
    type t
    @send external code: (t, int) => unit = "code"
    @send external send: (t, JSON.t) => Promise.t<JSON.t> = "send"
    @send external header: (t, string, string) => unit = "header"
  }

  @module("fastify") external make: createOption => t = "default"
  type listenOptions = {port: int, host: string}
  @send external listen: (t, listenOptions) => Promise.t<unit> = "listen"
  @send external get: (t, string, (request, Reply.t) => Promise.t<'data>) => unit = "get"
  @send external log: t => Js.t<'a> = "log"
  module Route = {
    type t
    type routeOptions = {
      method: string,
      url: string,
      schema: unit,
      preHandler: (request, Reply.t) => Promise.t<unit>,
      handler: (request, Reply.t) => unit,
    }
  }
  @send external register: (t, 'a) => unit = "register"
  @send external registerWithOptions: (t, 'a, staticOption) => unit = "register"
}

@module("@fastify/static") external fastifyStatic: 'a = "default"
let fastify = Fastify.make({logger: true})

fastify->Fastify.register(cors)
@val external importMetaUrl: string = "import.meta.url"

let dirname =
  importMetaUrl
  ->Node.Url.fileURLToPath
  ->Node.Path.dirname

switch staticRoot {
| None => {
    Console.log("STATIC_ROOT is not set, using dist")
    fastify->Fastify.registerWithOptions(
      fastifyStatic,
      {
        root: Node.Path.join(dirname, "../dist"),
      },
    )
  }
| Some(staticRoot) =>
  fastify->Fastify.registerWithOptions(
    fastifyStatic,
    {
      root: Node.Path.join(dirname, staticRoot),
    },
  )
}

let port = port->Option.flatMap(port => port->Int.fromString)->Option.getOr(3000)
let host = switch Node.Process.env->Dict.get("HOST") {
| Some(host) => host
| None => "0.0.0.0"
}

fastify->Fastify.get("/api/sheets", async (_, _) => {
  await Sheets.getSheetsData()
})

switch await fastify->Fastify.listen({port, host}) {
| exception exn => Console.log(exn)
| _ => Console.log("Server is running")
}
