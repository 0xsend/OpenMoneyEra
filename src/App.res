let example: Api.Sheets.data = {
  values: [
    ("Tweet ID", "Sendtag", "Tweet"),
    (
      "12f12312",
      "/ethen",
      "\"Cryptocurrency is not just a new form of money, but a new way to build financial infrastructure for the developing world.\" - \n@cdixon\n \n\n#OpenMoneyEra \nhttp://TheOpenMoneyEra.com\n\n/winston",
    ),
    (
      "12f12312",
      "/ethen",
      "\"Cryptocurrency is not just a new form of money, but a new way to build financial infrastructure for the developing world.\" - \n@cdixon\n \n\n#OpenMoneyEra \nhttp://TheOpenMoneyEra.com\n\n/winston",
    ),
  ],
}
let make = () => {
  <div className="p-6 bg-color0 h-full flex flex-col mx-auto max-w-screen-lg items-center">
    <header className="flex items-center justify-between border-b-2 border-b-color12 p-4">
      <div className="flex flex-col items-center gap-4">
        <h1 className="text-3xl font-semibold text-color12 "> {"Open Money Era"->React.string} </h1>
        <p className="text-xl font-semibold text-color12 ">
          {"Send the #OpenMoneyEra on Twitter and receive Send tips"->React.string}
        </p>
      </div>
    </header>
    <div className="flex flex-col gap-4 py-6 h-full">
      {example.values
      ->Array.mapWithIndex(((_, sendTag, tweet), i) => {
        switch i {
        | 0 => React.null
        | _ =>
          <div
            className="flex flex-col first:border-t-0 border-t-4 border-t-color1 first:pt-0 pt-4">
            <div className="flex flex-col p-2 ">
                <a
                  className="text-xl font-semibold  text-color10 w-0"
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
      ->React.array}
    </div>
  </div>
}
