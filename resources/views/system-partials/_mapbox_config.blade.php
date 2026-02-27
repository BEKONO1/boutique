<script>
    // Mapbox configuration from environment
    window.MAPBOX_TOKEN = "{{ config('services.mapbox.token', env('MAPBOX_TOKEN', '')) }}";

    // If Mapbox token exists, use it in the map configuration
    if (window.MAPBOX_TOKEN && window.MAPBOX_TOKEN.trim()) {
        // Token is available for Mapbox
        console.log('Mapbox token configured');
    } else {
        // Will fallback to OpenStreetMap in theme.min.js
        console.log('Using OpenStreetMap (no Mapbox token)');
    }
</script>
