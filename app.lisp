(defpackage :sdl2-game-tutorial/app
  (:use :cl)
  (:import-from :sdl2-game-tutorial/01-view-window)
  (:import-from :sdl2-game-tutorial/02-view-image))
(in-package :sdl2-game-tutorial/app)

;; 01��������ɥ���ɽ������
; (sdl2-game-tutorial/01-view-window:main)

;; 02��������ɽ������
(sdl2-game-tutorial/02-view-image:main)
