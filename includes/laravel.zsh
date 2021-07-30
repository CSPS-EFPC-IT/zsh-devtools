# |----------------------------------------------------------------------------
# | Start a process calling the scheduler every minute.
# |----------------------------------------------------------------------------
function laravel:scheduler() {
	while :
	do
		php artisan schedule:run
		echo "Sleeping 60 seconds..."
		sleep 60
	done
}
