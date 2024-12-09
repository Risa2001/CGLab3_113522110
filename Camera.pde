public class Camera {
    Matrix4 projection = new Matrix4();
    Matrix4 worldView = new Matrix4();
    int wid;
    int hei;
    float near;
    float far;
    Transform transform;

    Camera() {
        wid = 256;
        hei = 256;
        worldView.makeIdentity();
        projection.makeIdentity();
        transform = new Transform();
    }

    Matrix4 inverseProjection() {
        Matrix4 invProjection = Matrix4.Zero();
        float a = projection.m[0];
        float b = projection.m[5];
        float c = projection.m[10];
        float d = projection.m[11];
        float e = projection.m[14];
        invProjection.m[0] = 1.0f / a;
        invProjection.m[5] = 1.0f / b;
        invProjection.m[11] = 1.0f / e;
        invProjection.m[14] = 1.0f / d;
        invProjection.m[15] = -c / (d * e);
        return invProjection;
    }

    Matrix4 Matrix() {
        return projection.mult(worldView);
    }

    void setSize(int w, int h, float n, float f) {
        wid = w;
        hei = h;
        near = n;
        far = f;
        
        // TODO HW3
        // This function takes four parameters, which are 
        // the width of the screen, the height of the screen
        // the near plane and the far plane of the camera.
        // Where GH_FOV has been declared as a global variable.
        // Finally, pass the result into projection matrix.
        
        
        float aspect = (float) w / (float) h; // 計算寬高比
        float fov = GH_FOV;                   // 視野角度 (應已定義為全域變數)
        float tanHalfFov = (float) Math.tan(fov / 2); // tan(fov / 2)

        projection = Matrix4.Identity();
        projection.makeIdentity();

        projection.m[0] = 1.0f / (aspect * tanHalfFov); 
        projection.m[5] = 1.0f / tanHalfFov;            
        projection.m[10] = -(f + n) / (f - n);          
        projection.m[11] = -(2.0f * f * n) / (f - n);   
        projection.m[14] = -1.0f;                       
        projection.m[15] = 0.0f;
    }

    void setPositionOrientation(Vector3 pos, float rotX, float rotY) {

    }

    void setPositionOrientation(Vector3 pos, Vector3 lookat) {
        // TODO HW3
        // This function takes two parameters, which are the position of the camera and
        // the point the camera is looking at.
        // We uses topVector = (0,1,0) to calculate the eye matrix.
        // Finally, pass the result into worldView matrix.

        worldView = Matrix4.Identity();
        // 定義相機的頂向量（通常是世界的 Y 軸）
        Vector3 topVector = new Vector3(0, 1, 0);
    
        // caculate zAxis (zAxis = pos - lookat)
        Vector3 zAxis = pos.sub(lookat);
        zAxis.normalize(); 
    
        // caculate xAxis (xAxis = topVector × zAxis)
        Vector3 xAxis = Vector3.cross(topVector, zAxis);
        xAxis.normalize(); 
    
        // caculate yAxis (yAxis = zAxis × xAxis)
        Vector3 yAxis = Vector3.cross(zAxis, xAxis);; 
        
        worldView.m[0]  = xAxis.x;
        worldView.m[1]  = xAxis.y;
        worldView.m[2]  = xAxis.z;
        worldView.m[3]  = -Vector3.dot(xAxis, pos);
    
        worldView.m[4]  = yAxis.x;
        worldView.m[5]  = yAxis.y;
        worldView.m[6]  = yAxis.z;
        worldView.m[7]  = -Vector3.dot(yAxis, pos);
    
        worldView.m[8]  = zAxis.x;
        worldView.m[9]  = zAxis.y;
        worldView.m[10] = zAxis.z;
        worldView.m[11] = -Vector3.dot(zAxis, pos);
    
        worldView.m[12] = 0;
        worldView.m[13] = 0;
        worldView.m[14] = 0;
        worldView.m[15] = 1;
    }
}
