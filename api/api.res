module Sheets = Sheets



@val @scope(("process", "env"))
external port: option<string> = "PORT"

module Fastify = {
  type t
  type request

  module Reply = {
    type t
    @send external code: (t, int) => unit = "code"
    @send external send: (t, JSON.t) => Promise.t<JSON.t> = "send"
  }

  @module("fastify") external make: unit => t = "default"
  type listenOptions = {port: int}
  @send external listen: (t, listenOptions) => Promise.t<unit> = "listen"
  @send external get: (t, string, (request, Reply.t) => Promise.t<JSON.t>) => unit = "get"
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
  @send external register: (t, Route.t) => unit = "register"
}

let fastify = Fastify.make()

let port = port->Option.flatMap(port => port->Int.fromString)->Option.getOr(3000)

let tap = x => {
  Console.log(x)
  x
}

fastify->Fastify.get("/", async (_, _) => {
  "{hello: world}"->JSON.parseExn->tap
})

switch await fastify->Fastify.listen({port: port}) {
| exception exn => Console.log(exn)
| _ => Console.log("Server is running")
}
