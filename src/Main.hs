-- Actions
import XMonad.Actions.Navigation2D

-- Base
import System.Exit
import XMonad

-- Data
import Data.Monoid

-- Hooks
import XMonad.Hooks.EastGate
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.WindowSwallowing

-- Layouts
import XMonad.Layout.NoBorders (noBorders, smartBorders)
import XMonad.Layout.Tabbed

-- Utils
import XMonad.Util.EZConfig
import XMonad.Util.NamedScratchpad

import Data.Map qualified as M
import XMonad.StackSet qualified as W

myTerminal = "alacritty"

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

myBorderWidth = 0

myModMask = mod4Mask

myNormalBorderColor = "#dddddd"
myFocusedBorderColor = "#ff0000"

myLayout = avoidStrutsOn [U] (Full ||| tabbedAlways shrinkText myTabConfig)
  where
    myTabConfig = def { inactiveBorderColor = "#FF0000"
                      , inactiveColor = "#1c1b22"
                      , activeColor = "#42414d"
                      }

scratchpads = [NS "term" "alacritty -T scratchpad" queryTerm manageTerm]
  where
    queryTerm = title =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect xOffset yOffset width height
      where
        width = 0.9
        height = 0.9
        xOffset = 0.05
        yOffset = 0.05

myWorkspaces = ["web", "read", "notes", "chats", "term"] ++ map show [6 .. 9]

myManageHook =
  composeOne
    [ appName =? "Places" -?> doShift "web" <+> doRectFloat (W.RationalRect 0 0 0.5 0.5)
    , className =? "firefox" -?> doShift "web"
    , className =? "Zathura" -?> doShift "read"
    , className =? "obsidian" -?> doShift "notes"
    , className =? "TelegramDesktop" -?> doShift "chats"
    , className =? "Alacritty" -?> doShift "term"
    , isFullscreen -?> doFullFloat
    , isDialog -?> doRectFloat $ W.RationalRect 0 0 0.3 0.3
    -- namedScratchpadManageHook scratchpads
    ]

myStartupHook :: X ()
myStartupHook =
  spawn "myxmobar"

myHandleEventHook = swallowEventHook (className =? "Alacritty") (return True)

myKeys = 
    [ ("M-<Return>", spawn "alacritty")
    , ("M-q", kill)
    , ("M-<Tab>", sendMessage NextLayout)
    -- , ("M-S-<Tab>", setLayout $ XMonad.layoutHook conf)
    , ("M-f", spawn "firefox")
    , ("M-r", spawn "rofi -show drun")
    , ("M-o", namedScratchpadAction scratchpads "term")
    , ("M-S-b", sendMessage ToggleStruts)
    , ("M-S-r", restart "/run/current-system/sw/bin/myxmonad" True)
    , ("M-<Print>", spawn "screenshot-x")
    , ("M-S-e", io (exitWith ExitSuccess))
    ]

mySB = statusBarProp "xmobar" (pure xmobarPP)

myConfig = def
    { terminal = myTerminal
    , modMask = mod4Mask
    , layoutHook = myLayout
    , focusFollowsMouse = False
    , borderWidth = myBorderWidth
    , workspaces = myWorkspaces
    , normalBorderColor = "#dddddd"
    , focusedBorderColor = "#ff0000"
    , manageHook = myManageHook
    , startupHook = myStartupHook
    , handleEventHook = myHandleEventHook
    }

main = xmonad $ docks 
                . navigation2DP  def ("<Up>", "<Left>", "<Down>", "<Right>") [("M-",   windowGo  ), ("M-S-", windowSwap)] False
                . withSB mySB
                . withMetrics    def 
                $ myConfig
                `additionalKeysP` myKeys
