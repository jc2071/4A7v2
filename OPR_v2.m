clc; clear; close all;

Reference_data;

OPR_range = 3:1:50;
w0 = 200;
height = 9.5;
flight_range = 12000;
stages = 10;
stage_length =  flight_range*1000/stages;

beta_star = 2*sqrt(k1*k2);

co2_masses = zeros(1,length(OPR_range));
nox_masses = zeros(1,length(OPR_range));
impactr = zeros(1,length(OPR_range));

index = 1;

for OPR = OPR_range
    [T,p,rho,a] = ISA(height); % get ISA envioment conditions
    w0_stage = 200;
    mach_stage = zeros(1,stages);
    stage_fuel_used = zeros(1,stages);
    mass_co2 = 0;
    mass_nox = 0;
    for i = 1:1:stages
        ve_star = (w0_stage*1000*g/(0.5*rhosl*A))^0.5 *(k2/k1)^0.25; % Optimum EAS 
        nu = 1; % EAS ratio to optimium set to get best L/D
        EAS = nu*ve_star;
        TAS = ve_star/sqrt(rho/rhosl); % True Air Speed
        mach = TAS/a; % Mach number of flight (cruise)
        if mach >= 0.85
             mach = 0.85;
        end
        mach_stage(i) = mach;
        
        [mj,tj, peff] = jet(mach, FPR, feff); % jet mach, jet temp ratio, propulsive efficiency
        LD = (sqrt(k1*k2)*(nu^2 + 1/nu^2))^-1;
        cycle_efficiency = (1 - OPR^-0.17);
        H = peff * cycle_efficiency * treff * LD* LCV / g; % the range parameter for eacgh stage
        
        if i ==1
            weight_fuel = w0_stage*(0.015 + 1 - exp(-stage_length/H));
        else
            weight_fuel =  w0_stage*(1 - exp(-stage_length/H));
        end
        
        stage_fuel_used(i) = weight_fuel;
        w0_stage = w0_stage - weight_fuel;
        
        T02 = stag_temp(mach,height);
        
        nox = NOx(T02,teff,OPR)*weight_fuel*2*15.1*1000;
        co2 = 3088*weight_fuel*1000;
        
        mass_co2 = mass_co2 + co2;
        mass_nox = mass_nox + nox;
    end

    co2_masses(index) = mass_co2;
    nox_masses(index) = mass_nox;
    [noxim,co2im] = impact(height);
    impactr(index) = mass_co2*co2im + mass_nox*noxim;
    
    index = index +1;
    
end

figure(1)
hold on
plot(OPR_range,co2_masses*co2im/(flight_range*pmax),'-' ,'color','g','DisplayName', 'CO_2','linewidth',2)
plot(OPR_range,nox_masses*noxim/(flight_range*pmax),'-' ,'color','b','DisplayName', 'NO_x','linewidth',2)
plot(OPR_range,impactr/(flight_range*pmax),'-' ,'color','k','DisplayName', 'Sum impact','linewidth',2)

% uhuhil
%     
% 
% index =1;
% 
% for OPR = OPR_range
%     [T,p,rho,a] = ISA(height); % get ISA envioment conditions
%     w0_stage = 200;
%     mach_stage = zeros(1,stages);
%     stage_fuel_used = zeros(1,stages);
%     mass_co2 = 0;
%     mass_nox = 0;
%     
%     for i = 1:1:stages
%         ve_star = (w0_stage*1000*g/(0.5*rhosl*A))^0.5 *(k2/k1)^0.25; % Optimum EAS 
%         nu = 1; % EAS ratio to optimium set to get best L/D
%         EAS = nu*ve_star;
%         TAS = ve_star/sqrt(rho/rhosl); % True Air Speed
%         mach = TAS/a; % Mach number of flight (cruise)
%         w0_stage = w0_stage - 10;
%   
%         mach_stage(i) = mach;
%         
%         [mj,tj, peff] = jet(mach, FPR, feff); % jet mach, jet temp ratio, propulsive efficiency
%         LD = (sqrt(k1*k2)*(nu^2 + 1/nu^2))^-1;
%         cycle_efficiency = (1 - OPR^-0.17);
%         H = peff * cycle_efficiency * treff * LD* LCV / g; % the range parameter for eacgh stage
%         
%         if i ==1
%             weight_fuel = w0_stage*(0.015 + 1 - exp(-stage_length/H));
%         else
%             weight_fuel =  w0_stage*(1 - exp(-stage_length/H));
%         end
%         
%         stage_fuel_used(i) = weight_fuel;
%         w0_stage = w0_stage - weight_fuel;
%         
%         T02 = stag_temp(mach,height);
%         NOx(T02,teff,OPR)
%         nox = NOx(T02,teff,OPR)*weight_fuel*2*15.1*1000;
%         co2 = 3088*weight_fuel*1000;
%         
%         mass_co2 = mass_co2 + co2;
%         mass_nox = mass_nox + nox;
%     end
% 
%     co2_masses(index) = mass_co2;
%     nox_masses(index) = mass_nox;
%     impactr(index) = mass_cos*impact(height) + mass_nox*impact(height);
%     
%     index = index +1;
%     
% end

legend('location','best')
xlabel('OPR')
ylabel('Emissions g/PAX km')
xticks([0:5:100])
set(gca,'FontName','Times','FontSize',12)
box on
print('altitude','-depsc')

