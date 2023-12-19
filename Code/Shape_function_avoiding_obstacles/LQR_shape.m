
function l = LQR_shape(p1,p2,p3,p4)

way_x1 = [p1, p3];
ay1 = [p2, p4];

Q = eye(5);
R = eye(2);
dt = 0.1; 
base_r = 0.3;
mway_x_steer = deg2rad(90.0);
show_animation = true;
x_list = [];
y_list = [];
complete_x_list = [];
complete_y_list = [];
for m = 1:(length(way_x1)-1)
    if m ~= length(way_x1)-1
     %   m
        all_x = way_x1(m:m+1);
        all_y = ay1(m:m+1);
    else
        all_x = way_x1(m:end);
        all_y = ay1(m:end);
    end
    goal = [all_x(end), all_y(end)];
    intepolated_x = [];
    interpolater_y = [];
    interpolated_theta = [];
    % ck = [];
    step = dt;
    theta_list = [];
    prev_x = all_x(1);
    prev_y = all_y(1);
    new_steps = [];

    for i = 1:length(all_x)
        t_list = [];
        if all_x(i) ~= prev_x && all_y(i) == prev_y
            if all_x(i) > prev_x
                new_steps = prev_x:step:all_x(i);
            elseif all_x(i) < prev_x
                new_steps1 = all_x(i):step:prev_x;
                new_steps = fliplr(new_steps1);
            end
            intepolated_x = [intepolated_x, new_steps];
            interpolater_y = [interpolater_y, all_y(i)*ones(size(new_steps))];
        end

        if all_x(i) == prev_x && all_y(i) ~= prev_y
            if all_y(i) > prev_y
                new_steps = prev_y:step:all_y(i);
            elseif all_y(i) < prev_y
                new_steps1 = all_y(i):step:prev_y;
                new_steps = fliplr(new_steps1);
            end
            interpolater_y = [interpolater_y, new_steps];
            intepolated_x = [intepolated_x, all_x(i)*ones(size(new_steps))];
        end

        theta = atan2(all_y(i) - prev_y, all_x(i) - prev_x);
        t_list = [t_list, theta * ones(size(new_steps))];
        interpolated_theta = [interpolated_theta, t_list];
        prev_x = all_x(i);
        prev_y = all_y(i);
    end
    if length(intepolated_x) ==0
        break
    end

    complete_x_list = [complete_x_list, intepolated_x];
    complete_y_list = [complete_y_list, interpolater_y];
    ck = traj_curvature(interpolated_theta);
    % ck = [ck, ck(end)];  % Assuming the last value extends

    target_speed = 2;  % simulation parameter km/h -> m/s
    s = 0:step:target_speed;
    sp = ones(size(intepolated_x)) * target_speed;

    [t, x, y, ~, v] = model_update(all_x(1), all_y(1), interpolated_theta(1), sp(1), all_x, all_y, intepolated_x, interpolater_y, interpolated_theta, ck, sp, goal,Q,R,dt,base_r,mway_x_steer);
    x_list = [x_list, x];
    y_list = [y_list, y];
end

l=[x_list; y_list];



function curve_changes = traj_curvature(theta_val)
    curve_changes = zeros(size(theta_val));
    theta_val(1);
    prev_diff = theta_val(1);
    
    for i = 1:length(theta_val)
        theta_diff = theta_val(i) - prev_diff;
        prev_diff = theta_val(i);
        
        curve_changes(i) = theta_diff;
    end
    length(curve_changes)
    % curve_changes(end) = theta_diff;
end



function [t, x, y, theta, v] = model_update(x0, y0, theta0, v0, way_x, ay, x_est, y_est, theta_est, ck, speed_profile, goal, Q,R,dt,base_r,mway_x_steer)
    T = 500.0;  % mway_x simulation time
    goal_dis = 0.001;
    stop_speed = 0.2;
    state = struct('x', x0, 'y', y0, 'theta', theta0, 'v', v0);
    time = 0.0;
    x = state.x;
    y = state.y;
    theta = state.theta;
    v = state.v;
    t = 0.0;
    tolerance_dist = 10;
    e = 0.0;
    e_th = 0.0;
    idx = 0;
    dt = 0.01;  % Assuming a time step of 0.1 seconds

    while T >= time
        [dl, target_ind, e, e_th, ai] = lqr_cntrl(state, x_est, y_est, theta_est, ck, e, e_th, speed_profile, Q, R,dt,base_r);
        state = update(state, ai, dl, dt,mway_x_steer,base_r);

        if abs(state.v) <= stop_speed
            target_ind = target_ind + 1;
        end

        time = time + dt;

        % check goal
        dx = state.x - goal(1);
        dy = state.y - goal(2);
        if hypot(dx, dy) <= goal_dis
            % fprintf('Goal\n');
            break;
        end

        x = [x, state.x];
        y = [y, state.y];
        theta = [theta, state.theta];
        v = [v, state.v];
        t = [t, time];
        idx = idx + 1;
    end
end


function state = update(state, a, delta, dt, mway_x_steer, base_r)
    if delta >= mway_x_steer
        delta = mway_x_steer;
    end
    if delta <= -mway_x_steer
        delta = -mway_x_steer;
    end

    state.x = state.x + state.v * cos(state.theta) * dt;
    state.y = state.y + state.v * sin(state.theta) * dt;
    state.theta = state.theta + state.v / base_r * tan(delta) * dt;
    state.v = state.v + a * dt;
end

function K= dlqr(A, B, Q, R)
    x = Q;
    x_next = Q;
    nn = 150;
    eps = 0.01;
    for i = 1:nn
        x_next = A' * x * A - A' * x * B * inv(R + B' * x * B) * B' * x * A + Q;
        if max(abs(x_next - x)) < eps
            break;
        end
        x = x_next;
    end
    X = x_next;
    K = inv(B' * X * B + R) * (B' * X * A);
end

function [dl, target_ind, e, e_th, ai] = lqr_cntrl(state, x_est, y_est, theta_est, ck, pe, pth_e, sp, Q, R,dt,base_r)
    
    A = [1,dt,0,0,0;
        0,0,state.v,0,0;
        0,0,1,dt,0;
        0,0,0,0,0;
        0,0,0,0,1];
    B = [0 0;0 0;0 0;state.v / base_r 0;0 dt];
    K = dlqr(A, B, Q, R);
    [ind, e] = min_val(state, x_est, y_est, theta_est);
    v= state.v;
    tv = sp(ind);
    k = ck(ind);
    th_e = pi_range(state.theta - theta_est(ind));
    x = [e; (e - pe) / dt; th_e;(th_e - pth_e) / dt;v - tv];
    u_update = -K * x;
    diff = atan2(base_r * k, 1) + pi_range(u_update(1));
    a_v = u_update(2);
    dl = k * base_r * diff;
    target_ind = ind;
    e_th = th_e;
    ai = a_v;
end

function [ind, d_min] = min_val(state, x_est, y_est, theta_est)
    d = sqrt((state.x - x_est).^2 + (state.y - y_est).^2);
    [d_min, ind] = min(d);
    angle = pi_range(theta_est(ind) - atan2(y_est(ind) - state.y, x_est(ind) - state.x));
    if angle < 0
        d_min = -d_min;
    end
end

end

function out = pi_range(in_ang_rad)
 add_pi = in_ang_rad + pi;
 out = (add_pi) - floor((add_pi) / (2 * pi)) * (2 * pi) - pi;
end

