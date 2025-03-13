function writeObj(filename, mesh)
    % writeObj writes the mesh structure to an OBJ file.
    %
    % mesh should have fields:
    %   - vertices: an Nx3 matrix of vertex positions
    %   - faces: an Mx3 (or MxN) matrix of vertex indices
    
    fid = fopen(filename, 'w');
    if fid == -1
        error('Cannot open file for writing: %s', filename);
    end

    % Write vertices
    for i = 1:size(mesh.v, 1)
        fprintf(fid, 'v %.8f %.8f %.8f\n', mesh.v(i, :));
    end
    
    % Write faces
    for i = 1:size(mesh.f.v, 1)
        fprintf(fid, 'f');
        fprintf(fid, ' %d', mesh.f.v(i, :));
        fprintf(fid, '\n');
    end

    fclose(fid);
end
