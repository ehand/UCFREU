function bb = findActualRect(bb, shift)

for i=1:size(bb, 2)
    bb(i).rect(1) = (bb(i).rect(1)-1)*shift+1;
    bb(i).rect(2) = (bb(i).rect(2)-1)*shift+1;
    bb(i).rect(3) = (bb(i).rect(3)+1)*shift;
    bb(i).rect(4) = (bb(i).rect(4)+1)*shift;
end