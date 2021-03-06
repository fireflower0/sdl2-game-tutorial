(defpackage #:sdl2-game-tutorial
  (:use #:cl)
  (:import-from #:sdl2-game-tutorial/01-view-window)
  (:import-from #:sdl2-game-tutorial/02-view-image)
  (:import-from #:sdl2-game-tutorial/03-view-text)
  (:import-from #:sdl2-game-tutorial/04-view-2drendering)
  (:import-from #:sdl2-game-tutorial/05-input-key)
  (:import-from #:sdl2-game-tutorial/06-move-image)
  (:import-from #:sdl2-game-tutorial/07-system-window)
  (:import-from #:sdl2-game-tutorial/08-fps-timer)
  (:import-from #:sdl2-game-tutorial/09-animation)
  (:import-from #:sdl2-game-tutorial/10-message-window)
  (:import-from #:sdl2-game-tutorial/11-character-operation)
  (:import-from #:sdl2-game-tutorial/12-select-window)
  (:import-from #:sdl2-game-tutorial/13-traffic-restriction)
  (:export #:start))
(in-package #:sdl2-game-tutorial)

(defun start (&key id)
  (case id
    (1 (sdl2-game-tutorial/01-view-window:main))
    (2 (sdl2-game-tutorial/02-view-image:main))
    (3 (sdl2-game-tutorial/03-view-text:main))
    (4 (sdl2-game-tutorial/04-view-2drendering:main))
    (5 (sdl2-game-tutorial/05-input-key:main))
    (6 (sdl2-game-tutorial/06-move-image:main))
    (7 (sdl2-game-tutorial/07-system-window:main))
    (8 (sdl2-game-tutorial/08-fps-timer:main))
    (9 (sdl2-game-tutorial/09-animation:main))
    (10 (sdl2-game-tutorial/10-message-window:main))
    (11 (sdl2-game-tutorial/11-character-operation:main))
    (12 (sdl2-game-tutorial/12-select-window:main))
    (13 (sdl2-game-tutorial/13-traffic-restriction:main))
    (t (format t "Hello, SDL2~%"))))
