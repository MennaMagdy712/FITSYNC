@echo off
echo ========================================
echo   Starting Gym System Application
echo ========================================
echo.

REM Start Backend API
echo [1/2] Starting Backend API...
start "Backend API" cmd /k "cd /d GymSystemFlutterG03\GymSystemFlutterG03 && dotnet run --launch-profile http"

REM Wait for backend to start
echo Waiting for backend to initialize...
timeout /t 10 /nobreak > nul

REM Start Flutter App
echo [2/2] Starting Flutter App...
start "Flutter App" cmd /k "cd /d flutter project\gym_app && flutter run -d 65IFG6J7HEJRGINR"

echo.
echo ========================================
echo   Both services are starting...
echo   Backend: http://0.0.0.0:7165
echo   Flutter: Running on mobile device
echo ========================================
echo.
echo Press any key to exit this window...
pause > nul
