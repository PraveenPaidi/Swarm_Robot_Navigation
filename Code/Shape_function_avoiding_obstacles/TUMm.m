function path = TUMm(q,qd,gamma,sh);
% q
% qd
% gamma

R_0= 0.01;
syms 'z1' 'z'

%gamma = y+1;
%q=[0 -1.11];
%qd=[1 -1];

beta_0 = R_0 - ((z1-q(1,1)).^2 + (z-q(1,2)).^2);
nav = gamma.^2 ./ (gamma.^2 + beta_0);

dndx_sym = vpa(diff(nav,'z1'));
dndy_sym = vpa(diff(nav,'z'));

p = [q'- 1.5*ones(size(q'))]; 
m = q;
dt = 0.01;
ti=dt;
s_x_y=1;

while ti < 0.5
    for t=1:1
	    z1 = q(t,1);
	    z = q(t,2);
	    dndx = double(subs(dndx_sym));
	    dndy = double(subs(dndy_sym));
	    si = sh*[double(subs(vpa(diff(gamma,'z'))));-double(subs(vpa(diff(gamma,'z1'))))]';
	    grad = [-dndx;-dndy]';
	    q(t,:) = q(t,:) - (1./(norm(grad))).*grad*dt + si*dt;

    end
    %if [floor(x) floor(y)]==qd
     %   break
    sqrt((z1-qd(1,1))^2+(z-qd(1,2))^2);
    if sqrt((z1-qd(1,1))^2+(z-qd(1,2))^2)<0.1
        break

    end
    m = q;
    m1 = q'-ones(size(q'))-0.5*ones(size(q'));
    % m1
    p = [p,m1];

    ti=ti+dt;
    % scatter(m(1,1)-1, m(1,2)-1, 50, 'blue', 'filled');
    % pause(0.01)
    % %plot(m(1,1),m(1,2),'r-','Linewidth',3);
    % hold on;

   
end
path = p;

%figure;
%plot(path(1,1:2:end),path(1,2:2:end),'r-','Linewidth',3);
%hold on;
%xlim([-3, 3]); % Set x-axis limits from -3 to 3
%ylim([-3, 3]); % Set x-axis limits from -3 to 3
%plot(path(1,1),path(1,2),'k*','Markersize',10,'Linewidth',2);

end






