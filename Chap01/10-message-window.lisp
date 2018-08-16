;;; 07：システムウィンドウ表示

;; SDL2ライブラリのロード
(ql:quickload :sdl2)         ; SDL2ライブラリ
(ql:quickload :sdl2-image)   ; 画像ファイル読み込み、描画関連のライブラリ
(ql:quickload :sdl2-ttf)     ; フォントの描画関連のライブラリ

;; 外部ファイルをロード
(load "../GameUtility/texture.lisp" :external-format :utf-8)
(load "../GameUtility/fps-timer.lisp" :external-format :utf-8)

;; ウィンドウのサイズ
(defconstant +screen-width+  640) ; 幅
(defconstant +screen-height+ 480) ; 高さ

;; 画像ファイルへのパス
(defparameter *img-syswin* "../Material/graphics/system/systemwindow.png")
(defparameter *img-pause*  "../Material/graphics/system/text-pause.png")

;; フォントファイルへのパス
(defparameter *font-file-path* "../Material/fonts/ipaexg.ttf")

;; アニメーションフレーム
(defparameter *pause-frame* 6)

;; フレーム数インクリメント
(defmacro frame-incf (frame)
  `(if (= ,frame most-positive-fixnum)
       (setf ,frame 1)
       (incf ,frame)))

;; システムウィンドウレンダリング処理
(defmethod system-window-render (tex x y w h)
  (with-slots (width height) tex
    (let* ((width-size   (/ width  3))
           (height-size  (/ height 3))
           (right-pos    (- width (* (/ width 3) 3)))
           (center-pos   (- width (* (/ width 3) 2)))
           (left-pos     (- width (* (/ width 3) 1)))
           (upper-left   (sdl2:make-rect right-pos  right-pos  width-size height-size))
           (upper-right  (sdl2:make-rect left-pos   right-pos  width-size height-size))
           (bottom-left  (sdl2:make-rect right-pos  left-pos   width-size height-size))
           (bottom-right (sdl2:make-rect left-pos   left-pos   width-size height-size))
           (upper        (sdl2:make-rect center-pos right-pos  width-size height-size))
           (bottom       (sdl2:make-rect center-pos left-pos   width-size height-size))
           (left         (sdl2:make-rect right-pos  center-pos width-size height-size))
           (right        (sdl2:make-rect left-pos   center-pos width-size height-size))
           (center       (sdl2:make-rect center-pos center-pos width-size height-size)))
      ;; Four Corners
      (tex-render tex x                      y                       :clip upper-left  )
      (tex-render tex (+ x (- w width-size)) y                       :clip upper-right )
      (tex-render tex x                      (+ y (- h height-size)) :clip bottom-left )
      (tex-render tex (+ x (- w width-size)) (+ y (- h height-size)) :clip bottom-right)
      ;; Upper/Bottom
      (tex-render2 tex (+ x width-size) y                       (- w (* width-size 2)) height-size :clip upper )
      (tex-render2 tex (+ x width-size) (+ y (- h height-size)) (- w (* width-size 2)) height-size :clip bottom)
      ;; Right/Left
      (tex-render2 tex x                      (+ y height-size) width-size (- h (* height-size 2)) :clip left  )
      (tex-render2 tex (+ x (- w width-size)) (+ y height-size) width-size (- h (* height-size 2)) :clip right )
      ;; Center
      (tex-render2 tex (+ x width-size) (+ y height-size) (- w (* width-size 2)) (- h (* height-size 2)) :clip center))))

(defun message-window (renderer syswin-tex pause-tex clip font text-message)
  (let ((str-tex (tex-load-from-string renderer font text-message)))
    ;; ベースウィンドウ表示
    (system-window-render syswin-tex 25 345 590 110)
    ;; テキスト表示
    (tex-render str-tex 40 360)
    ;; ポーズアニメーション表示
    (tex-render pause-tex 305 445 :clip clip)))

;; SDL2ライブラリ初期化＆終了処理
(defmacro with-window-renderer ((window renderer) &body body)
  ;; SDLの初期化と終了時の処理をまとめて実行
  `(sdl2:with-init (:video)
     ;; ウィンドウ作成処理を実行
     (sdl2:with-window (,window
                        :title "SDL2 Tutorial 01" ; タイトル
                        :w     +screen-width+     ; 幅
                        :h     +screen-height+    ; 高さ
                        :flags '(shown))          ; :shownや:hiddenなどのパラメータを設定できる
       ;; ウィンドウの2Dレンダリングコンテキストを生成
       (sdl2:with-renderer (,renderer
                            ,window
                            :index -1
                            ;; レンダリングコンテキストを生成するときに使われるフラグの種類
                            ;; :software      : ソフトウェア レンダラー
                            ;; :accelerated   : ハードウェア アクセラレーション
                            ;; :presentvsync  : 更新周期と同期
                            ;; :targettexture : テクスチャへのレンダリングに対応
                            :flags '(:accelerated :presentvsync))
         (sdl2-image:init '(:png)) ; sdl2-imageを初期化(扱う画像形式はPNG ※他にもJPGとTIFが使える)
         (sdl2-ttf:init)           ; sdl2-ttfを初期化
         ,@body
         (sdl2-image:quit)         ; sdl2-image終了処理
         (sdl2-ttf:quit)))))       ; sdl2-ttf終了処理

(defun main ()
  (with-window-renderer (window renderer)
    ;; 画像ファイル読み込み、画像情報の取得などを行う
    (let* ((syswin-tex     (tex-load-from-file renderer *img-syswin*))
           (pause-tex      (tex-load-from-file renderer *img-pause*))
           (font           (sdl2-ttf:open-font *font-file-path* 20))
           ;; アニメーション用
           (clip           (sdl2:make-rect 0 0 30 16))
           ;; FPS用変数
           (fps-timer      (make-instance 'fps-timer))
           (cap-timer      (make-instance 'fps-timer))
           (fixed-fps      60)
           (tick-per-frame (floor 1000 fixed-fps))
           (frames         0))

      (timer-start fps-timer)
      
      ;; イベントループ(この中にキー操作時の動作や各種イベントを記述していく)
      (sdl2:with-event-loop (:method :poll)
        ;; キーが押下されたときの処理
        (:keydown (:keysym keysym)
                  ;; keysymをスキャンコードの数値(scancode-value)に変換して、キー判定処理(scancode=)を行う
                  (if (sdl2:scancode= (sdl2:scancode-value keysym) :scancode-escape)
                      (sdl2:push-event :quit))) ; Escキーが押下された場合、quitイベントをキューに加える
        ;; この中に描画処理など各種イベントを記述していく
        (:idle ()
               (timer-start cap-timer)
               
               ;; 作図操作(矩形、線、およびクリア)に使用する色を設定
               (sdl2:set-render-draw-color renderer 0 0 0 255)
               ;; 現在のレンダーターゲットを上記で設定した色で塗りつぶして消去
               (sdl2:render-clear renderer)

               ;; レンダリング処理
               (message-window renderer syswin-tex pause-tex clip font "こんにちは、世界！")
               
               ;; 遅延処理
               (let ((time (timer-get-ticks cap-timer)))
                 (when (< time tick-per-frame)
                   (sdl2:delay (floor (- tick-per-frame time)))))

               ;; フレーム数をインクリメント
               (frame-incf frames)

               ;; アニメーション更新
               (when (zerop (rem frames tick-per-frame))
                 (setf (sdl2:rect-y clip) (* (rem frames *pause-frame*) (sdl2:rect-height clip))))
               
               ;; レンダリングの結果を画面に反映
               (sdl2:render-present renderer))
        ;; 終了イベント
        (:quit () t)))))

;; main関数を呼び出して実行
(main)