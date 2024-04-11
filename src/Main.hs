import XMonad
import Data.Monoid
import System.Exit
import XMonad.Layout.Tabbed
import XMonad.Util.EZConfig
import XMonad.Hooks.EastGate
import XMonad.Util.NamedScratchpad

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myTerminal      = "alacritty"

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

myBorderWidth   = 1

myModMask       = mod4Mask

myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]

myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#ff0000"

myLayout = tiled ||| Mirror tiled ||| Full ||| simpleTabbed
  where
    tiled   = Tall nmaster delta ratio
    nmaster = 1
    ratio   = 1/2
    delta   = 3/100

scratchpads = [ NS "term" "alacritty -T scratchpad" queryTerm manageTerm]
  where 
    queryTerm = title =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect xOffset yOffset width height
      where
        width = 0.9
        height = 0.9
        xOffset = 0.05
        yOffset = 0.05

myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , namedScratchpadManageHook scratchpads 
    ]

myStartupHook :: X ()
myStartupHook = 
  spawn "myxmobar"

main = xmonad $ (withMetrics def) $ myConfig

myConfig = def
  { terminal = myTerminal
  , modMask = mod4Mask
  , layoutHook = myLayout
  , focusFollowsMouse = False
  , borderWidth = 1
  , workspaces = myWorkspaces
  , normalBorderColor = "#dddddd"
  , focusedBorderColor = "#ff0000"
  , manageHook = myManageHook
  , startupHook = myStartupHook
  }
  `additionalKeysP`
  [ ("M-f", spawn "firefox")
  , ("M-r", spawn "rofi -show drun")
  , ("M-o", namedScratchpadAction scratchpads "term")
  ]
