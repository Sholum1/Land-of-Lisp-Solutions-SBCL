(require 'usocket)

(defparameter my-socket (usocket:socket-listen #(127 0 0 1) 4321 :reuse-address t))
(defparameter my-stream (usocket:socket-stream (usocket:socket-accept my-socket)))

(read my-stream)

(print "What up, Client!" my-stream)
(force-output my-stream)

(close my-stream)
