@val @scope(("import", "meta", "env")) external baseUrl: option<string> = "VITE_BASE_URL"
@val @scope(("window", "location")) external origin: string = "origin"
module Window: {
  type t = Dom.window
  @get external innerWidth: t => int = "innerWidth"
  module EventListener: {
    type type_ = | @as("resize") Resize | @as("wheel") Wheel
    type options = {passive: bool}
    @private @send
    external make: (Dom.window, type_, 'a => unit, ~options: options=?) => unit = "addEventListener"
    @private @send external remove: (Dom.window, type_, 'a => unit) => unit = "removeEventListener"
  }
  let addEventListener: (
    Dom.window,
    EventListener.type_,
    'a => unit,
    ~options: EventListener.options=?,
  ) => unit
  let removeEventListener: (Dom.window, EventListener.type_, 'a => unit) => unit
}
type exn += FailedToFetchSheets({message: string})
let fetchSheet: 'a => promise<Js.Array.t<Api.Types.value>>
let arrayToColumns: (array<'a>, 'b) => array<array<'a>>
type token = {name: string, symbol: string, address: string, decimals: float}
let ethToken: token
let usdcToken: token
let sendToken: token
module TipPill: {
  @react.component
  let make: (
    ~icon: React.element,
    ~amount: float,
    ~displayAmount: string=?,
    ~sendtag: string,
    ~token: token,
    ~className: string=?,
  ) => Jsx.element
}
module TweetList: {
  @react.component
  let make: (~columns: array<array<Api.Types.value>>) => React.element
}
@react.component
let make: unit => Jsx.element
