@echo off
echo ===================================================================
echo Starting RoadFix - Smart Pothole Reporting ^& Road Safety Platform
echo Prototype - Demonstration Data (India)
echo ===================================================================
echo Opening application in your web browser...
start http://localhost:8080/index.html
echo.
echo Running local web server on http://localhost:8080
echo Press Ctrl+C to stop the server when done.
echo ===================================================================
python -m http.server 8080
