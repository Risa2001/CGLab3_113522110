public class GameObject {
    Transform transform;
    Mesh mesh;
    String name;
    Shader shader;

    GameObject() {
        transform = new Transform();
    }

    GameObject(String fname) {
        transform = new Transform();
        setMesh(fname);
        String[] sn = fname.split("\\\\");
        name = sn[sn.length - 1].substring(0, sn[sn.length - 1].length() - 4);
        shader = new Shader(new DepthVertexShader(), new DepthFragmentShader());
    }

    void reset() {
        transform.position.setZero();
        transform.rotation.setZero();
        transform.scale.setOnes();
    }

    void setMesh(String fname) {
        mesh = new Mesh(fname);
    }

    void Draw() {
        Matrix4 MVP = main_camera.Matrix().mult(localToWorld());
        for (int i=0; i<mesh.triangles.size(); i++) {
            Triangle triangle = mesh.triangles.get(i);
            Vector3[] position = triangle.verts;
            Vector4[] gl_Position = shader.vertex.main(new Object[]{position}, new Object[]{MVP});
            Vector3[] s_Position = new Vector3[3];
            for (int j = 0; j<gl_Position.length; j++) {
                s_Position[j] = gl_Position[j].homogenized();
            }
            Vector3[] boundbox = findBoundBox(s_Position);
            float minX = map(min( max(boundbox[0].x, -1.0 ), 1.0), -1.0, 1.0, 0.0, renderer_size.z - renderer_size.x);
            float maxX = map(min( max(boundbox[1].x, -1.0 ), 1.0), -1.0, 1.0, 0.0, renderer_size.z - renderer_size.x);
            float minY = map(min( max(boundbox[0].y, -1.0 ), 1.0), -1.0, 1.0, 0.0, renderer_size.w - renderer_size.y);
            float maxY = map(min( max(boundbox[1].y, -1.0 ), 1.0), -1.0, 1.0, 0.0, renderer_size.w - renderer_size.y);
            
            for (int y = int(minY); y < maxY; y++) {
                for (int x = int(minX); x < maxX; x++) {
                    float rx=map(x, 0.0 , renderer_size.z - renderer_size.x, -1, 1);
                    float ry=map(y, 0.0, renderer_size.w - renderer_size.y, -1, 1);
                    if (!pnpoly(rx, ry, s_Position)) continue;
                    int index = y * int(renderer_size.z - renderer_size.x) + x;
                    
                    float z = getDepth(rx, ry, s_Position );
                    Vector4 c = shader.fragment.main(new Object[]{new Vector3(rx, ry, z)});
                    
                    if (GH_DEPTH[index] > z) {
                        GH_DEPTH[index] = z;
                        renderBuffer.pixels[index] = color(c.x * 255, c.y*255, c.z*255);
                    }
                }
            }
        }        
        update();
    }

    void update() {
    }
    
    void debugDraw() {
        Matrix4 MVP = main_camera.Matrix().mult(localToWorld());
        Matrix4 modelMatrix = localToWorld(); // model local to world
    
        Vector3 cam_position = main_camera.Matrix().translation();
    
        for (int i = 0; i < mesh.triangles.size(); i++) {
            Triangle triangle = mesh.triangles.get(i);
    
            // caculated traingle world space toppoint
            Vector3 worldA = modelMatrix.mult(triangle.verts[0].getVector4(1.0)).homogenized();
            Vector3 worldB = modelMatrix.mult(triangle.verts[1].getVector4(1.0)).homogenized();
            Vector3 worldC = modelMatrix.mult(triangle.verts[2].getVector4(1.0)).homogenized();
    
            // 計算法向量
            Vector3 edge1 = worldB.sub(worldA);
            Vector3 edge2 = worldC.sub(worldA);
            Vector3 normal = Vector3.cross(edge1, edge2).unit_vector();
    
            // cam direction
            Vector3 camDirection = cam_position.sub(worldA).unit_vector();
    
            // Backculling
            if (Vector3.dot(normal, camDirection) <= 0) {     //如果法向量與視線方向向量積<0
                continue; 
            }
    
            // mapping to 2D
            Vector3[] img_pos = new Vector3[3];
            for (int j = 0; j < 3; j++) {
                img_pos[j] = MVP.mult(triangle.verts[j].getVector4(1.0)).homogenized();
            }
    
            // mapping to pixel
            for (int j = 0; j < img_pos.length; j++) {
                img_pos[j] = new Vector3(
                    map(img_pos[j].x, -1, 1, renderer_size.z, renderer_size.x),
                    map(img_pos[j].y, -1, 1, renderer_size.w, renderer_size.y),
                    img_pos[j].z()
                );
            }
    
            // draw triangle edge
            CGLine(img_pos[0].x, img_pos[0].y, img_pos[1].x, img_pos[1].y);
            CGLine(img_pos[1].x, img_pos[1].y, img_pos[2].x, img_pos[2].y);
            CGLine(img_pos[2].x, img_pos[2].y, img_pos[0].x, img_pos[0].y);
        }
    }

    /*void debugDraw() {
        Matrix4 MVP = main_camera.Matrix().mult(localToWorld());
        for (int i = 0; i < mesh.triangles.size(); i++) {
            Triangle triangle = mesh.triangles.get(i);
            Vector3[] img_pos = new Vector3[3];
            for (int j = 0; j < 3; j++) {
                img_pos[j] = MVP.mult(triangle.verts[j].getVector4(1.0)).homogenized();
            }

            for (int j = 0; j < img_pos.length; j++) {
                img_pos[j] = new Vector3(map(img_pos[j].x, -1, 1, renderer_size.x, renderer_size.z),
                        map(img_pos[j].y, -1, 1, renderer_size.y, renderer_size.w), img_pos[j].z);
            }

            CGLine(img_pos[0].x, img_pos[0].y, img_pos[1].x, img_pos[1].y);
            CGLine(img_pos[1].x, img_pos[1].y, img_pos[2].x, img_pos[2].y);
            CGLine(img_pos[2].x, img_pos[2].y, img_pos[0].x, img_pos[0].y);
        }
    }*/

    String getGameObjectName() {
        return name;
    }

    Matrix4 localToWorld() {
        // TODO HW3
        // You need to calculate the model Matrix here.
        //transform.position; 
        //transform.scale;  
        //transform.rotation; 
    
        // position and scale matrix
        Matrix4 translationMatrix = Matrix4.Trans(transform.position); 
        Matrix4 scaleMatrix = Matrix4.Scale(transform.scale);          
    
        // rotation matrix of x, y, z
        Matrix4 rotationMatrixX = Matrix4.RotX(transform.rotation.x);
        Matrix4 rotationMatrixY = Matrix4.RotY(transform.rotation.y);
        Matrix4 rotationMatrixZ = Matrix4.RotZ(transform.rotation.z);
    
        Matrix4 rotationMatrix = rotationMatrixZ.mult(rotationMatrixY).mult(rotationMatrixX);
        return translationMatrix.mult(rotationMatrix).mult(scaleMatrix);
    }

    Matrix4 worldToLocal() {
        return Matrix4.Scale(transform.scale.inv()).mult(Matrix4.RotZ(-transform.rotation.z))
                .mult(Matrix4.RotX(-transform.rotation.x)).mult(Matrix4.RotY(-transform.rotation.y))
                .mult(Matrix4.Trans(transform.position.mult(-1)));
    }

    Vector3 forward() {
        return (Matrix4.RotZ(transform.rotation.z).mult(Matrix4.RotX(transform.rotation.y))
                .mult(Matrix4.RotY(transform.rotation.x)).zAxis()).mult(-1);
    }
}
