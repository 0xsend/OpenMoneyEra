
module Sheets = {
  @spice
  type data = {values: array<array<string>>}

  @spice
  type status = | @spice.as("INVALID_ARGUMENT") INVALID_ARGUMENT

  @spice
  type error = {
    code: int,
    message: string,
    status: status,
  }
}

@spice
type value = {
  tweetId?: string,
  sendTag?: string,
  tweet?: string,
  name?: string,
  imageUrl?: string,
}

@spice
type data = array<value>