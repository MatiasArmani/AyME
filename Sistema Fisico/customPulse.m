function y = customPulse(t)
    % Parámetros del pulso
    pulseStart = 0.3;     % Tiempo donde inicia el pulso
    pulseWidth = 0.2;     % Duración del pulso alto
    pulseDown = 0.4;      % Duración del pulso bajo
    amplitude = 6.28;      % Amplitud del pulso

    % Inicializar la salida
    y = zeros(1,size(t));
    
    % Generar el pulso
    for i = 1:length(t)
        if t(i) >= pulseStart && t(i) < (pulseStart + pulseWidth)
            y(i) = amplitude;
        elseif t(i) >= (pulseStart + pulseWidth) && t(i) < (pulseStart + pulseWidth + pulseDown)
            y(i) = -amplitude;
        else
            y(i) = 0;
        end
    end
end