function y = myFastConvolution(x, h)

len_of_sig = length(x);
len_of_ir = length(h);

y = zeros(len_of_sig + len_of_ir - 1, 1);

%%
%Blocking impulse response
[~, ublocked_ir] = generateBlocks(h, 44100, 128, 128);
num_128h_blocks = size(ublocked_ir, 2);

num_hblocks = 1;

%Computing number of non-uniform blocks in impulse response
for i = 1 : 0.5 : num_128h_blocks
    if num_hblocks >= num_128h_blocks
        num_hblocks = i / 0.5;
        break;
    else
        num_hblocks = num_hblocks + (2^floor(i));
    end
end

h = [h;zeros((2 ^ num_hblocks) * 128, 1)];
blocked_fft_ir = cell(num_hblocks, 1);

%Generating blocks 
start_hidx = 1;
for i = 1 : 0.5 : (num_hblocks / 2) + 0.5
    blocked_temp_ir = zeros(128 * (2 ^ (floor(i) - 1)), 1);
    blocked_temp_ir = h(start_hidx : start_hidx - 1 + 128 * (2 ^ (floor(i) - 1)));
    blocked_fft_ir{(i - 0.5) / 0.5, 1} = fft(blocked_temp_ir(1 : end));
    start_hidx = start_hidx + (2 ^ (floor(i) - 1)) + 1;
end


%%
%Blocking input signal
[~, blocked_signal] = generateBlocks(x, 44100, 128, 128);
%%
%
num_blocks = size(blocked_signal, 2);

temp_y = zeros(len_of_sig + len_of_ir - 1, 1);

for i = 1 : num_blocks
   
    for j = 1 : num_hblocks
        
        if (i - j + 1) < 1
            break;
        end
%         temp_y = zeros(length(blocked_signal(:, i - j + 1)) + length(blocked_fft_ir{j}) - 1, 1);
        temp_y = cell(1);
        
        blocked_fft = fft([blocked_signal(:, i - j + 1); zeros(length(blocked_fft_ir{j}) - length(blocked_signal(:, i - j + 1)), 1)]);
        temp_fft = blocked_fft .* blocked_fft_ir{j};
        temp_y{1} = ifft(temp_fft);
        
        
%         temp_y(:, 1) = myFreqConv(blocked_signal(:, i - j + 1), blocked_fft_ir{j});
        start_idx = ((i - 1) * 128) + 1;
        y(start_idx : start_idx + length(temp_y{1}) - 1, 1) = y(start_idx : start_idx + length(temp_y{1}) - 1, 1) + temp_y{1};
        
        output(:,1) = y(((i - 1) * 128) + 1 : i * 128);
%         temp_y = blocked_signal(:, i - j + 1) * blocked_fft_ir{j};
        
    end
    
end
%     temp_y = 

%     len_of_sig = length(x);
%     len_of_ir = length(h);
%     conv_size = (2 * len_of_ir) - 1;
%     
%     y = zeros(len_of_sig + len_of_ir - 1, 1);
%     
%     [~, blocked_signal] = generateBlocks(x, 44100, len_of_ir, len_of_ir);
%     
%     num_blocks = size(blocked_signal, 2);
%     
%     temp_y = zeros(conv_size, num_blocks);
%     
%     y(1 : conv_size) = myFreqConv(blocked_signal(:, 1), h);
%     temp_y(:, 1) = y(1 : conv_size);
%     
%     for i = 2 : num_blocks
%         
%         temp_y(:, i) = myFreqConv(blocked_signal(:, i), h);
%         
%         start_of_overlap = ((i - 1) * len_of_ir + 1);
%         end_of_overlap = start_of_overlap + (conv_size - len_of_ir) - 1;
%         
%         start_of_block = ((i - 1) * len_of_ir) + 1;
%         end_of_block = ((i - 1) * len_of_ir) + conv_size;
%         
%         overlap = y(start_of_overlap : end_of_overlap) + temp_y(1 : conv_size - len_of_ir, i);
% 
%         y( start_of_block : end_of_block) = [overlap ; temp_y(conv_size - len_of_ir + 1 : end, i)];
%         
%     end
end  