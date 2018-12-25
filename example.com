$TTL	86400
@		IN	SOA	ns.example.com. root.example.com. (
		1	; Serial
		10800	; Refresh
		3600	; Retry
		604800	; Expire
		3600)	; Minimum
;
@		IN	NS	ns.example.com.
@		IN	A	10.1.2.3
ns		IN	A	127.0.0.1