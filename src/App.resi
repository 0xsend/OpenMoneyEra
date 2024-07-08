@val @scope(("import", "meta", "env"))
external baseUrl: option<string> = "VITE_BASE_URL"
type exn +=  FailedToFetchSheets({message: string})
let fetchSheet: 'a => promise<Js.Json.t>
module TweetList: {
  @react.component
  let make: (~items: array<(string, string, string)>) => React.element
}
@react.component
let make: unit => Jsx.element
