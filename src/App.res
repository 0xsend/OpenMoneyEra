@val @scope(("import", "meta", "env")) external baseUrl: option<string> = "VITE_BASE_URL"
@val @scope(("window", "location")) external origin: string = "origin"

module Window = {
  type t = Dom.window

  @get external innerWidth: t => int = "innerWidth"
  module EventListener = {
    type type_ =
      | @as("resize") Resize
      | @as("scroll") Scroll
      | @as("click") Click
      | @as("wheel") Wheel
    type options = {passive: bool}

    @private @send
    external make: (Dom.window, type_, 'a => unit, ~options: options=?) => unit = "addEventListener"
    @private @send external remove: (Dom.window, type_, 'a => unit) => unit = "removeEventListener"
  }
  let addEventListener = EventListener.make
  let removeEventListener = EventListener.remove
}

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
    switch (await Response.json(resp))->Api.Types.data_decode {
    | exception _ => raise(FailedToFetchSheets({message: "Failed to fetch sheet"}))
    | Error(_) => raise(FailedToFetchSheets({message: "Failed to decode sheet data"}))
    | Ok(data) => data
    }
  } else {
    raise(FailedToFetchSheets({message: "Failed to fetch sheet"}))
  }
}

let arrayToColumns = (_a: array<'a>, _cols): array<array<'a>> => {
  %raw(`[...Array(_cols).keys()].map(c => _a.filter((_, i) => i % _cols === c))`)
}

module TweetList = {
  @react.component
  let make = (~columns: array<array<Api.Types.value>>) => {
    columns
    ->Array.mapWithIndex((column, i) => {
      Console.log(column)
      <div className="flex flex-col gap-4 w-full" key={"column" ++ i->Int.toString}>
        {column
        ->Array.map(item => {
          switch item {
          | {
              tweetId: ?Some(tweetId),
              sendTag: ?Some(sendTag),
              tweet: ?Some(tweet),
              ?name,
              ?imageUrl,
            } =>
            <div className="flex flex-col p-4 md:rounded-xl bg-color1 w-full h-min" key={tweetId}>
              <div className="flex flex-col p-2">
                <div className="relative rounded-xl">
                  <img
                    src={imageUrl->Option.getOr(
                      "https://raw.githubusercontent.com/0xsend/assets/main/2024/04/send-og-image-old.png",
                    )}
                    className="w-full rounded-xl object-cover"
                  />
                  <div
                    className="flex flex-col items-start justify-end gap-4 p-6 absolute bottom-0 w-full h-full bg-opacity-50 from-transparent to-color0 bg-gradient-to-b rounded-xl">
                    <h2 className="text-3xl text-color12 font-semibold ">
                      {name->Option.getOr("Anonymous")->React.string}
                    </h2>
                    <a
                      className="text-xl font-semibold  text-color10 w-full hover:text-color12 hover:cursor-pointer "
                      href={`https://send.app/${sendTag}`}
                      target="_blank">
                      <div className="flex items-center justify-between w-full">
                        <p className="text-color10"> {sendTag->React.string} </p>
                        <RightArrowIcon />
                      </div>
                    </a>
                  </div>
                </div>
                <div
                  className="xl:text-lg text-md text-color11 break-words whitespace-pre-wrap pt-6 tracking-wide">
                  {tweet->React.string}
                </div>
              </div>
            </div>
          | _ => React.null
          }
        })
        ->React.array}
      </div>
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
    onError: error => {
      Console.error(error)
    },
  })

  let (vw, setVw) = React.useState(() => Window.innerWidth(window))
  let (columns, setColumns) = React.useState(() => None)

  let (numColumns, setNumColumns) = React.useState(() => 1)

  let handleWindowSizeChange = React.useCallback0(() => {
    setVw(_ => window->Window.innerWidth)
  })

  React.useEffect0(() => {
    window->Window.addEventListener(Resize, handleWindowSizeChange)
    Some(() => window->Window.removeEventListener(Resize, handleWindowSizeChange))
  })

  React.useEffect1(() => {
    switch vw {
    | vw if vw < 640 => setNumColumns(_ => 1)
    | vw if vw < 1024 => setNumColumns(_ => 2)
    | vw if vw >= 1024 => setNumColumns(_ => 3)
    | _ => ()
    }
    None
  }, [vw])

  React.useEffect2(() => {
    switch (queryResult.data, numColumns) {
    | (Some(items), numColumns) =>
      setColumns(_ => Some(items->Array.slice(~start=0, ~end=-1)->arrayToColumns(numColumns)))
    | _ => setColumns(_ => None)
    }
    None
  }, (queryResult.data, numColumns))

  <div className="xl:p-20 md:p-8 bg-color0 h-full flex flex-col ">
    <header className="flex justify-between xl:p-0 xl:pb-10 p-6 pb-10 ">
      <div className="flex flex-col gap-4">
        <a
          href="https://x.com/hashtag/OpenMoneyEra"
          target="_blank"
          className="text-3xl font-bold text-color12 hover:cursor-pointer uppercase">
          {"Open Money Era"->React.string}
        </a>
        <p className="text-xl  text-color3 ">
          {"Send the #OpenMoneyEra on Twitter and receive Send tips"->React.string}
        </p>
      </div>
    </header>
    <div className="flex flex-row gap-4 py-6 h-full">
      {switch (queryResult, columns) {
      | ({isLoading: true}, _) =>
        <p className="text-xl font-semibold text-color12 "> {"Loading..."->React.string} </p>
      | ({error, isError: true}, _) =>
        <>
          <p className="text-xl font-semibold text-red-400 "> {"Error"->React.string} </p>
          <p className="text-xl font-semibold text-red-400 ">
            {error
            ->Nullable.toOption
            ->Option.flatMap(e => e->JSON.stringifyAny)
            ->Option.getOr("Unknown error")
            ->React.string}
          </p>
        </>
      | ({isLoading: false, isError: false}, Some(columns)) => <TweetList columns />
      | _ =>
        <p className="text-xl font-semibold text-red-400 ">
          {`Unexpected error...`->React.string}
        </p>
      }}
    </div>
  </div>
}
