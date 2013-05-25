(ns test.express.app
	(:require [express :as express])
	(:use [wisp.sequence :only [map first second]]
				[wisp.string :only [join]]))

(defmacro h-get
	[path & callbacks]
	`(fn [app]
		(.get app ~path ~callbacks)))

(defmacro h-put
	[path & callbacks]
	`(fn [app]
		(.put app ~path ~callbacks)))

(defmacro h-post
	[path & callbacks]
	`(fn [app]
		(.post app ~path ~callbacks)))

(defmacro h-del
	[path & callbacks]
	`(fn [app]
		(.del app ~path ~callbacks)))

(defmacro h-all
	[path & callbacks]
	`(fn [app]
		(.all app ~path ~callbacks)))

;; (defmacro authenticate
	;; [handler]
	;; `(fn [req res next]
		;; (.end res "UNAUTHORIZED"))
		;; (next))
	;; handler)

;; Pages

(defmacro render
	[view & options]
		`(.render res ~view ~options))

(defmacro handle
	[name & body]
	`(defn ~name [req res] ~@body))	

(defmacro middleware
	[name & body]
	`(defn ~name [req res next] ~@body))

(defmacro resource-index
	[name] ;; & middlewares
	`(h-get (+ "/" ~name)
		(fn [req res]
			(.json res { 
					:method 'req.method
					:url 'req.url
				}))))

(defmacro resource-create
	[name] ;; & middlewares
	`(h-post (+ "/" ~name)
		(fn [req res]
			(.json res { 
					:method 'req.method
					:url 'req.url
				}))))

(defmacro resource-show
	[name] ;; & middlewares
	`(h-get (+ "/" ~name "/:id")
		(fn [req res]
			(.json res { 
					:method 'req.method
					:url 'req.url
					:id 'req.params.id 
				}))))

(defmacro resource-update
	[name] ;; & middlewares
	`(h-put (+ "/" ~name "/:id")
		(fn [req res]
			(.json res { 
					:method 'req.method
					:url 'req.url
					:id 'req.params.id 
				}))))

(defmacro resource-delete
	[name] ;; & middlewares
	`(h-del (+ "/" ~name "/:id")
		(fn [req res]
			(.json res { 
					:method 'req.method
					:url 'req.url
					:id 'req.params.id 
				}))))

(middleware authenticate 
	"Authenticates request"
	(if true
		(.end res "UNAUTHORIZED")
		(next)))

(handle home 
	"The home page :)"
	(render :home 
		{ :user 
			{ :name "Paul" } }))

;; Handlers

(def handlers [
	;; Global handlers
	;; (h-all "*" authenticate)
	;; Pages routes
	(h-get "/" authenticate home)
	(h-get "/foo" (fn [req res] 
		(.end res "bar")))
	])

(defn rest-resources
	"Loads restful resources handlers"
	[resources]
	(map (fn [resource]
		(.push handlers (resource-index resource))
		(.push handlers (resource-create resource))
		(.push handlers (resource-show resource))
		(.push handlers (resource-update resource))
		(.push handlers (resource-delete resource)))
	resources))

;; (def resources [:users :feeds :entries])
(rest-resources [:users :feeds :entries])

(defn create-app
	[handler]
	(let [app (express)]
		;; Add our handlers add  to our application
		(map (fn [handler] (handler app)) handlers)
		app))
		
(defn start-app
	([port]
		(do
			(console.log "Starting app on port:" port)
			(let [app (create-app)]
				;; Configure the application
				
				(.listen app port)))))

;; Set env to development by default
(let [env (:NODE_ENV process.env)]
	(if (== env undefined)
		(set! process.env.NODE_ENV :development)
		nil))

(console.log (:NODE_ENV process.env))

(start-app 3000)
