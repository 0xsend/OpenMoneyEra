@val @scope(("import", "meta", "env")) external baseUrl: option<string> = "VITE_BASE_URL"
@val @scope(("window", "location")) external origin: string = "origin"

module Window = {
  type t = Dom.window

  @get external innerWidth: t => int = "innerWidth"
  module EventListener = {
    type type_ = | @as("resize") Resize | @as("wheel") Wheel
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

type token = {
  name: string,
  symbol: string,
  address: string,
}

let ethToken = {
  name: "Ethereum",
  symbol: "ETH",
  address: "eth",
}
let usdcToken = {
  name: "USD Coin",
  symbol: "USDC",
  address: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913",
}
let sendToken = {
  name: "Send",
  symbol: "SEND",
  address: "0x3f14920c99BEB920Afa163031c4e47a3e03B3e4A",
}

module TipPill = {
  @react.component
  let make = (
    ~icon: React.element,
    ~amount: string,
    ~sendtag: string,
    ~token: token,
    ~className: string="",
  ) => {
    let href = `https://send.app/send/confirm?recipient=${sendtag}&amount=${amount}&sendToken=${token.address}`

    <a
      href={href}
      target="_blank"
      className={"hover:scale-105 transition-all rounded-md  hover:cursor-pointer px-2 py-1 flex flex-row items-center justify-around gap-1  font-mono" ++
      " " ++
      className}>
      <p className="text-sm text-center leading-3"> {`+${amount}`->React.string} </p>
      <div className="w-4 h-4 flex justify-center items-center"> {icon} </div>
    </a>
  }
}

module TweetList = {
  @react.component
  let make = (~columns: array<array<Api.Types.value>>) => {
    columns
    ->Array.mapWithIndex((column, i) => {
      <div className="flex flex-col gap-14 w-full" key={"column" ++ i->Int.toString}>
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
                    className="w-full rounded-xl object-cover min-w-52 min-h-52"
                  />
                  <div
                    className="flex flex-col items-start justify-end gap-4 p-6 absolute bottom-0 w-full h-full bg-opacity-50 from-transparent to-color0 bg-gradient-to-b rounded-xl">
                    <h2 className="text-3xl text-color12 font-semibold ">
                      {name->Option.getOr("")->React.string}
                    </h2>
                    <div className="flex items-center justify-between w-full">
                      <a
                        className="flex-1 text-xl font-semibold  text-color10 w-full hover:text-color12 hover:cursor-pointer "
                        href={`https://send.app/${sendTag}`}
                        target="_blank">
                        <p className="text-color10"> {("/" ++ sendTag)->React.string} </p>
                      </a>
                    </div>
                  </div>
                </div>
                <div
                  className="xl:text-lg text-md text-color11 break-words whitespace-pre-wrap pt-6 tracking-wider leading-6">
                  {tweet->React.string}
                </div>
                <div className="w-full flex items-center justify-end gap-2 flex-1 pt-4">
                  <TipPill
                    icon={<USDCIcon />}
                    amount="1.00"
                    sendtag={sendTag}
                    token=usdcToken
                    className="bg-usdc text-color12"
                  />
                  <TipPill
                    icon={<ETHIcon />}
                    amount=".001"
                    sendtag={sendTag}
                    token=ethToken
                    className="bg-eth"
                  />
                  <TipPill
                    icon={<SENDIcon />}
                    amount="1000"
                    sendtag={sendTag}
                    token=sendToken
                    className="bg-color10"
                  />
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
    | vw if vw < 768 => setNumColumns(_ => 1)
    | vw if vw < 1280 => setNumColumns(_ => 2)
    | vw if vw >= 1280 => setNumColumns(_ => 3)
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
    <header
      className="flex flex-col md:flex-row justify-between xl:p-0 xl:pb-10 p-6 md:pb-10 items-center ">
      <div className="flex flex-col gap-4">
        <div className="flex flex-row justify-between items-center">
          <h1 className="text-3xl lg:text-4xl font-bold text-color12 uppercase">
            {"Open Money Era"->React.string}
          </h1>
          <div className="flex flex-row ">
            <div
              className="flex w-20 h-20 items-center justify-center mr-[-1rem] shadow-lg z-50">
              <USDCToken />
            </div>
            <div
              className="flex w-20 h-20 items-center justify-center mr-[-1rem] shadow-lg z-40">
              <ETHToken />
            </div>
            <div className="flex w-20 h-20 items-center justify-center">
              <SENDToken />
            </div>
          </div>
        </div>
        <div className="text-xl  text-color3">
          {"Send the"->React.string}
          <a
            href="https://x.com/hashtag/OpenMoneyEra"
            target="_blank"
            className="text-xl  text-color10">
            {" #OpenMoneyEra "->React.string}
          </a>
          {"hashtag on X and receive $USDC, $ETH, and $SEND Tips"->React.string}
        </div>
      </div>
    </header>
    <div className="flex flex-row gap-14 py-6 h-full">
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
