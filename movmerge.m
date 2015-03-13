function im_last = movmerge(h2b_file, gem_file)
I_max = 255;
cross_hair_len = 2;
min_y = cross_hair_len + 1;
min_x = cross_hair_len + 1;
clock_height = 24;
clock_width = 110;
h2b_reader = VideoReader(h2b_file);
gem_reader = VideoReader(gem_file);
n_frm = h2b_reader.NumberOfFrames;
assert(n_frm == gem_reader.NumberOfFrames, 'inconsistent number of frames');
idx_chtag = strfind(h2b_file, 'ch1.mp4');
assert(~isempty(idx_chtag), 'bad pattern of input file name');
outfile = [h2b_file(1 : idx_chtag - 1), 'rgb.mov'];
mov_writer = VideoWriter(outfile, 'MPEG-4');
mov_writer.open();
for f = 1 : n_frm
    frm = h2b_reader.read(f);
    height = size(frm, 1);
    max_y = height - cross_hair_len;
    width = size(frm, 2);
    max_x = width - cross_hair_len;
    nuc_msk = frm(:, :, 1) > 15;
    % save the clock
    bw_clock = nuc_msk(1 : clock_height, 1 : clock_width);    
    % remove chunk by opening (eroding, then dilating)
    nuc_msk = bwmorph(nuc_msk, 'open', 1);
    % segment nuclei to determine cenroids
    [L, n_cells] = bwlabel(nuc_msk);
    rp = regionprops(L, 'centroid');
    % read geminin file and create a linear combination of
    % original image and log-transformed image.
    frm = gem_reader.read(f);
    ch = double(frm(:, :, 2));
    ch(ch == 0) = 1;
    log_gem = floor(log2(ch) * 16);
    frm(:, :, 2) = log_gem + ch / 2;
    % red and blue get half of green for brighter appearance
    frm(:, :, 1) = frm(:, :, 2) / 2;
    frm(:, :, 3) = frm(:, :, 1);
    % overlay crosshairs and clock;
    for k = 1 : 3
        ch = frm(:, :, k);
        for n = 1 : n_cells
            x0 = round(rp(n).Centroid(1));
            if x0 < min_x || x0 > max_x
                continue
            end
            y0 = round(rp(n).Centroid(2));
            if y0 < min_y || y0 > max_y
                continue
            end            
            for y = y0 - cross_hair_len : y0 + cross_hair_len
                ch(y, x0) = I_max;
            end
            for x = x0 - cross_hair_len : x0 + cross_hair_len
                ch(y0, x) = I_max;
            end
        end
        ch(1 : clock_height, 1 : clock_width) = bw_clock * I_max;
        frm(:, :, k) = ch;
    end
    % write this frame into the output file
    mov_writer.writeVideo(frm);
    disp(f);
end
mov_writer.close();
im_last = frm;
