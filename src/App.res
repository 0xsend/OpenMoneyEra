@val @scope(("import", "meta", "env"))
external baseUrl: option<string> = "VITE_BASE_URL"
@val @scope(("window", "location"))
external origin: string = "origin"

exception FailedToFetchSheets({message: string})
let fetchSheet = async _ => {
  let baseUrl = baseUrl->Option.getOr(origin)

  let resp = await fetch(
    `${baseUrl}/api/sheets`,
    {
      method: #GET,
      headers: Headers.fromObject({
        "content-type": "application/json",
        "accept": "application/json",
      }),
    },
  )

  if Response.ok(resp) {
    await Response.json(resp)
  } else {
    raise(FailedToFetchSheets({message: "Failed to fetch sheet"}))
  }
}

module TweetList = {
  @react.component
  let make = (~items) => {
    items
    ->Array.mapWithIndex(((id, sendTag, tweet), i) => {
      switch i {
      | x if x == items->Array.length - 1 => React.null
      | _ =>
        <div
          className="flex flex-col first:border-t-0 border-t-4 border-t-color1 first:pt-0 pt-4"
          key={id}>
          <div className="flex flex-col p-2 ">
            <a
              className="text-xl font-semibold  text-color10 w-0 hover:text-color12 hover:cursor-pointer"
              href={`https://send.app/${sendTag}`}
              target="_blank">
              {sendTag->React.string}
            </a>
            <div
              className="text-md font-semibold text-color12 break-words whitespace-pre-wrap my-4 mx-2 px-4 border-l border-l-color10">
              {tweet->React.string}
            </div>
          </div>
        </div>
      }
    })
    ->React.array
  }
}

@react.component
let make = () => {
  let queryResult = ReactQuery.useQuery({
    queryFn: fetchSheet,
    queryKey: ["sheet"],
    /*
     * Helper functions to convert unsupported TypeScript types in ReScript
     * Check out the module ReactQuery_Utils.res
     */
    refetchOnWindowFocus: ReactQuery.refetchOnWindowFocus(#bool(false)),
  })

  let handleData = data => {
    switch Api.Types.data_decode(data) {
    | Error(_) => <p className="text-xl font-semibold text-red-400 "> {"Error"->React.string} </p>
    | Ok({values}) => <TweetList items={values->Array.toReversed} />
    }
  }

  <div className="p-6 bg-color0 h-full flex flex-col mx-auto max-w-screen-lg items-center">
    <header className="flex items-center justify-between border-b-2 border-b-color12 p-4">
      <div className="flex flex-col items-center gap-4">
        <a
          href="https://x.com/hashtag/OpenMoneyEra"
          target="_blank"
          className="text-3xl font-semibold text-color12 hover:cursor-pointer">
          {"Open Money Era"->React.string}
        </a>
        <p className="text-xl font-semibold text-color12 ">
          {"Send the #OpenMoneyEra on Twitter and receive Send tips"->React.string}
        </p>
      </div>
    </header>
    <div className="flex flex-col gap-4 py-6 h-full">
      {switch queryResult {
      | {isLoading: true} =>
        <p className="text-xl font-semibold text-color12 "> {"Loading..."->React.string} </p>
      | {data: Some(data), isLoading: false, isError: false} => handleData(data)
      | _ =>
        <p className="text-xl font-semibold text-red-400 ">
          {`Unexpected error...`->React.string}
        </p>
      }}
    </div>
  </div>
}
