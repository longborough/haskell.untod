module Untod.Process
    where

import Data.List
import Data.Maybe
import Data.Time
import Text.Read (readMaybe)

import Untod.Data
import Untod.Formatters
import Untod.LeapSecTab

tBase = UTCTime {
    utctDay = fromGregorian 1900 1 1
  , utctDayTime = 0.0
}
pBase = UTCTime {
    utctDay = fromGregorian 1966 1 3
  , utctDayTime = 0.0
}
uBase = UTCTime {
    utctDay = fromGregorian 1970 1 1
  , utctDayTime = 0.0
}

ptDelta = diffUTCTime pBase tBase
utDelta = diffUTCTime uBase tBase

processAll :: [String] -> Uargs -> Uwork -> [Int] -> [String]
processAll [] a w z
    | runmode a == DATE = processAll [uNow w] a w z
    | otherwise = ["No data provided"]
processAll l a w z =
    formatHeaders (headers a) (csv a) ++
    processData l a w z

processData :: [String] -> Uargs -> Uwork -> [Int] -> [String]
processData [] _ _ _ = []
processData (v:vs) a w z =
    processZones v a w z ++
    processData vs a w z

processZones :: String -> Uargs -> Uwork -> [Int] -> [String]
processZones [] _ _ _ = []
processZones v a w (z:zs) =
    processOne v a w z ++
    processZones v a w zs
processZones _ _ _ _ = []

processOne :: String -> Uargs -> Uwork -> Int -> [String]
processOne v a w z = [result] where
    result = case runmode a of
        TOD  -> processFromTOD  v a w z
        DATE -> processFromDATE v a w z
        PMC  -> processFromPMC  v a w z
        UNIX -> processFromUNIX v a w z
        CSEC -> processFromCSEC v a w z

processFromTOD  :: String -> Uargs -> Uwork -> Int -> String
processFromTOD  v a w z = r where
    r = if isNothing xtod
      then
          ptod ++ " is not valid hexadecimal"
      else
        joinRow (rSep w)
        [ rtod, rdate, rtime, rzone, rjul
        , rday, rpmc, runix, rleap ]
       ++ rnote
    rtod  = formatTod itod (tSep w)
    rdate = formatYMD xdate
    rtime = formatHMS xdate
    rjul  = formatJul xdate
    rzone = formatZone (tickmode a) z
    rday  = formatDay xdate
    rpmc  = formatPmc $ calcPmc z xdate
    runix = formatUnix (csv a) $ calcUnix 0 udate
    rleap = formatLsec (csv a) (tickmode a) lsec
    rnote = formatAnnot a
    xtod = readMaybe ("0x" ++ ptod) :: Maybe Integer
    itod = fromJust xtod
    ptod = padTod (padmode a) v
    lsec = lsSearchByTOD (tickmode a) itod
    tdiff = fromIntegral $ lsec - tAdj w - z
    udiff = fromIntegral $ lsec - tAdj w
    xdate = addUTCTime (0.000001 * fromIntegral itod - tdiff) tBase
    udate = addUTCTime (0.000001 * fromIntegral itod - udiff) tBase

processFromDATE :: String -> Uargs -> Uwork -> Int -> String
processFromDATE v a w z = r where
    r = if isNothing xdate
      then
          v ++ " is not a recognisable date/time"
      else
        joinRow (rSep w)
        [ rtod, rdate, rtime, rzone, rjul
        , rday, rpmc, runix, rleap ]
       ++ rnote
    rtod = formatTod ltod (tSep w)
    rdate = formatYMD $ fromJust xdate
    rtime = formatHMS $ fromJust xdate
    rjul  = formatJul  $ fromJust xdate
    rzone = formatZone (tickmode a) z
    rday  = formatDay  $ fromJust xdate
    rpmc  = formatPmc  $ calcPmc z udate
    runix = formatUnix (csv a) $ calcUnix z udate
    rleap = formatLsec (csv a) (tickmode a) lsec
    rnote = formatAnnot a
    xdate = getdate v
    udate = fromJust xdate
    tdate = addUTCTime ldiff udate
    ltod = round $ (1000000 *) $ diffUTCTime tdate tBase
    ldiff = fromIntegral $ lsec - tAdj w - z
    udiff = fromIntegral $ lsec - tAdj w
    lsec = lsSearchByDay (tickmode a) (utctDay udate)

processFromPMC :: String -> Uargs -> Uwork -> Int -> String
processFromPMC v a w z = r where
    r = if isNothing inval
      then
          v ++ " is not valid whatever!"
      else
        joinRow (rSep w)
        [ rtod, rdate, rtime, rzone, rjul
        , rday, rpmc, runix, rleap ]
       ++ rnote
    inval = getpmc v  
    pmin = fromJust inval
    psec = 60 * pmin
    dsec = (psec +) $ round ptDelta
    tsec = dsec - toInteger (z + tAdj w)
    rsec = tsec + toInteger lsec - round utDelta
    lsec = lsSearchByTOD (tickmode a) (1000000 * tsec)
    -- tdiff = toInteger $ z + tAdj w
    rtod  = formatTod  (1000000 * (tsec + toInteger lsec)) (tSep w)
    rdate = formatYMD  ldate
    rtime = formatHMS  ldate
    rjul  = formatJul  ldate
    ldate = addUTCTime (fromIntegral dsec) tBase 
    rday  = formatDay  ldate
    rzone = formatZone (tickmode a) z
    rpmc  = formatPmc  $ fixPmc pmin
    runix = formatUnix (csv a) rsec
    rleap = formatLsec (csv a) (tickmode a) lsec
    rnote = formatAnnot a

getdate :: String -> Maybe UTCTime
getdate s = if isNothing d
    then ptime "%Y.%j@%T%Q" j
    else d where
        t = s ++ drop (length s) "1900-01-01@00:00:00.000000000"
        j = s ++ drop (length s) "1900.001@00:00:00.000000000"
        d = ptime "%F@%T%Q" t

getpmc :: String -> Maybe Integer
getpmc [] = Nothing
getpmc ('-':ss) = Nothing
getpmc s = readMaybe ("0x" ++ s) :: Maybe Integer

calcUnix :: Int -> UTCTime -> Integer
calcUnix z t = toInteger $ (z +) $ fromInteger $ floor $ diffUTCTime t uBase

calcPmc :: Int -> UTCTime -> Maybe Integer
calcPmc z t = fixPmc x where
    x = toInteger $ (z +) $ floor $ diffUTCTime t pBase

fixPmc :: Integer -> Maybe Integer
fixPmc i = if i >= 0 && i < 2^64
        then Just i
        else Nothing

ptime :: String -> String -> Maybe UTCTime
ptime = parseTimeM False defaultTimeLocale

processFromUNIX :: String -> Uargs -> Uwork -> Int -> String
processFromUNIX v a w z = undefined

processFromCSEC :: String -> Uargs -> Uwork -> Int -> String
processFromCSEC v a w z = undefined

joinRow :: String -> [String] -> String
joinRow d s = init $ joinR d s

joinR :: String -> [String] -> String
joinR  _ [] =  []
joinR d (s:ss) = s ++ d ++ joinR d ss

-- ======================================================================
-- Process From Template
-- ======================================================================
processFromXyz :: String -> Uargs -> Uwork -> Int -> String
processFromXyz v a w z = r where
    r = if isNothing inval
      then
          idata ++ " is not valid whatever!"
      else
        joinRow (rSep w)
        [ rtod, rdate, rtime, rzone, rjul
        , rday, rpmc, runix, rleap ]
       ++ rnote
    idata = deriveId v  
    inval = deriveIn idata  
    rtod  = deriveTod  undefined
    rdate = deriveYMD  undefined
    rtime = deriveHMS  undefined
    rjul  = deriveJul  undefined
    rzone = formatZone (tickmode a) z
    rday  = deriveDay  undefined
    rpmc  = derivePmc  undefined
    runix = deriveUnix undefined
    rleap = deriveLsec undefined
    rnote = formatAnnot a

    deriveId   = undefined
    deriveIn   = undefined
    deriveTod  = undefined
    deriveYMD  = undefined
    deriveHMS  = undefined
    deriveJul  = undefined
    deriveDay  = undefined
    derivePmc  = undefined
    deriveUnix = undefined
    deriveLsec = undefined
