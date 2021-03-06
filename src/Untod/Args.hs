module Untod.Args (
    utOpts
    ) where
import Untod.Version
import Untod.Data
import Options.Applicative

utargs :: Parser Uargs
utargs = Uargs
      <$> (
            flag' DATE
          ( long "date"
            <> short 'd'
            <> help "Convert from Date/Time (default)" )
        <|> flag' TOD
          ( long "tod"
            <> short 'o'
            <> help "Convert from TOD" )
        <|> flag' PMC
          ( long "pmc"
            <> short 'm'
            <> help "Convert from PMC" )
        <|> flag' UNIX
          ( long "unix"
            <> short 'u'
            <> help "Convert from Unix seconds" )
        <|> flag' CSEC
          ( long "seconds"
            <> short 's'
            <> help "Convert from 20th Century seconds" )
        <|> pure DATE
          )
      <*> switch
          ( long "clipboard"
            <> short 'c'
            <> help "Input values from clipboard" )
      <*> switch
          ( long "csv"
            <> help "Output in CSV format" )
      <*> switch
          ( long "headers"
            <> help "Output column headers" )
      <*> switch
          ( long "annot"
            <> short 'a'
            <> help "Annotate plain output with run mode" )
      <*> switch
          ( long "zulu"
            <> short 'z'
            <> help "Also show Zulu offset" )
      <*> (
            flag' UTC
          ( long "gmt"
            <> short 'g'
            <> help "UTC with keao-seconds (default)" )
        <|> flag' LOR
          ( long "loran"
            <> short 'l'
            <> help "Ignore leap-seconds -- LORAN/IBM" )
        <|> flag' TAI
          ( long "tai"
            <> short 't'
            <> help "Ignore leap-seconds -- TAI (International Atomic Clock" )
        <|> pure UTC
          )
      <*> (
            flag' L
          ( long "lpad"
            <> help "Pad TOD with zeroes on left" )
        <|> flag' R
          ( long "rpad"
            <> help "Pad TOD with zeroes on right (default is intelligent padding)" )
        <|> pure I
          )
      <*> ( optional $ strOption
            (  long "input"
            <> short 'i'
            <> metavar "<filename>"
            <> help "Input values from a file ( - for STDIN )" )
            )
      <*> ( optional $ option auto
            (  long "azone"
            <> metavar "<offset>"
            <> help "Alternative time offset ([-+]n.n) [env: UNTOD_AZONE=]" )
            )
      <*> ( optional $ option auto
            (  long "lzone"
            <> metavar "<offset>"
            <> help "Override local time offset ([-+]n.n) [env: UNTOD_LZONE=]" )
            )
      <*>   ( length <$> many
              (flag' ()
                ( long "version" <> short 'v'
                <> help "Show version; more -v flags, more info")
              )
            )
      <*> ( optional $ many $ argument str
            (  metavar "<value...>"
            <> help "Values for conversion" )
            )
      <*> switch
          ( short 'x' )
  
utOpts = info (utargs <**> helper)
    ( fullDesc
    <> progDesc ("Converts among TOD, Date/Time, PARS Perpetual Minute Tick, "
    ++ "Unix seconds, and 20th century seconds for UTC, TAI or LORAN/IBM")
    <> header ("untod " ++ utVersion ++ " - a Swiss Army knife for TOD and other clocks")
    )
