(require 'usocket)

(defparameter my-stream (usocket:socket-stream (usocket:socket-connect #(127 0 0 1) 4321)))

(print "Yo Server!" my-stream)
(force-output my-stream)

(read my-stream)

(close my-stream)
