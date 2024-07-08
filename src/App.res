@val @scope(("import", "meta", "env"))
external baseUrl: option<string> = "VITE_BASE_URL"

exception FailedToFetchSheets({message: string})
let fetchSheet = async _ => {
  let baseUrl = baseUrl->Option.getOr("http://localhost:3000")
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

  <div className="p-6 bg-color0 h-full flex flex-col mx-auto max-w-screen-lg items-center">
    <header className="flex items-center justify-between border-b-2 border-b-color12 p-4">
      <div className="flex flex-col items-center gap-4">
        <a href="https://x.com/hashtag/OpenMoneyEra" className="text-3xl font-semibold text-color12 hover:cursor-pointer"> {"Open Money Era"->React.string} </a>
        <p className="text-xl font-semibold text-color12 ">
          {"Send the #OpenMoneyEra on Twitter and receive Send tips"->React.string}
        </p>
      </div>
    </header>
    <div className="flex flex-col gap-4 py-6 h-full">
      {switch queryResult {
      | {isLoading: true} => <p className="text-xl font-semibold text-color12 "> {"Loading..."->React.string} </p>
      | {data: Some(data), isLoading: false, isError: false} =>
        switch Api.Types.data_decode(data) {
        | Error(_) => "Error"->React.string
        | Ok(data) =>
          data.values
          ->Array.mapWithIndex(((_, sendTag, tweet), i) => {
            switch i {
            | 0 => React.null
            | _ =>
              <div
                className="flex flex-col first:border-t-0 border-t-4 border-t-color1 first:pt-0 pt-4">
                <div className="flex flex-col p-2 ">
                  <a
                    className="text-xl font-semibold  text-color10 w-0 hover:text-color12 hover:cursor-pointer"
                    href={`https://send.app/${sendTag}`}>
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
      | _ => <p className="text-xl font-semibold text-red-400 ">{`Unexpected error...`->React.string} </p>
      }}
    </div>
  </div>
}
