public void CGLine(float x1, float y1, float x2, float y2) {
    stroke(0);
    line(x1, y1, x2, y2);
}

public boolean outOfBoundary(float x, float y) {
    if (x < 0 || x >= width || y < 0 || y >= height)
        return true;
    return false;
}

public void drawPoint(float x, float y, color c) {
    int index = (int) y * width + (int) x;
    if (outOfBoundary(x, y))
        return;
    pixels[index] = c;
}

public float distance(Vector3 a, Vector3 b) {
    Vector3 c = a.sub(b);
    return sqrt(Vector3.dot(c, c));
}

boolean pnpoly(float x, float y, Vector3[] vertexes) {
    // TODO HW2
    // You need to check the coordinate p(x,v) if inside the vertexes.
    int n = vertexes.length;
    int inside = 0;

    for (int i = 0; i < n; i++) {
        float x1 = vertexes[i].x;
        float y1 = vertexes[i].y;
        float x2 = vertexes[(i + 1) % n].x;
        float y2 = vertexes[(i + 1) % n].y;

        if (((y1 > y) != (y2 > y)) && (x < (x2 - x1) * (y - y1) / (y2 - y1) + x1))
            inside += 1; 
    }
    if (inside % 2 == 1)
        return true;
    else
        return false;

}

public Vector3[] findBoundBox(Vector3[] v) {    
    // TODO HW2
    // You need to find the bounding box of the vertexes v.

    Vector3 recordminV = new Vector3(999);
    Vector3 recordmaxV = new Vector3(0);

    for (Vector3 vertex : v) {
        if (vertex.x < recordminV.x) 
            recordminV.x = vertex.x;
        if (vertex.y < recordminV.y) 
            recordminV.y = vertex.y;
        if (vertex.x > recordmaxV.x) 
            recordmaxV.x = vertex.x;
        if (vertex.y > recordmaxV.y) 
            recordmaxV.y = vertex.y;
    }
    Vector3[] result = { recordminV, recordmaxV };
    return result;
}
public static Vector3 findIntersection(double x1, double y1, double x2, double y2, 
                                        double x3, double y3, double x4, double y4) {
    double denominator = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    if (denominator == 0) {
        return null; // 平行或共線
    }

    double t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denominator;
    double u = ((x1 - x3) * (y1 - y2) - (y1 - y3) * (x1 - x2)) / denominator;

    // 判斷參數 t 和 u 是否在 [0,1] 範圍內
    if (t >= 0 && t <= 1 && u >= 0 && u <= 1) {
        double x = x1 + t * (x2 - x1);
        double y = y1 + t * (y2 - y1);
        Vector3 p = new Vector3((float)x, (float)y, 0);
        return p; // 返回交點
    }

    return null; // 不相交
}

public Vector3[] Sutherland_Hodgman_algorithm(Vector3[] points, Vector3[] boundary) {
    ArrayList<Vector3> input = new ArrayList<Vector3>();
    ArrayList<Vector3> output = new ArrayList<Vector3>();
    for (int i = 0; i < points.length; i += 1) {
        input.add(points[i]);
    }

    // TODO HW2
    // You need to implement the Sutherland Hodgman Algorithm in this section.
    // The function you pass 2 parameter. One is the vertexes of the shape "points".
    // And the other is the vertices of the "boundary".
    // The output is the vertices of the polygon.
    float xmin = Math.min(boundary[0].x, boundary[2].x);
    float xmax = Math.max(boundary[0].x, boundary[2].x);
    float ymin = Math.min(boundary[0].y, boundary[2].y);
    float ymax = Math.max(boundary[0].y, boundary[2].y);
    boolean outbound = false;
    for (int i = 0; i< input.size(); i++){ //if any point out of bound?
        if (input.get(i).x>xmax || input.get(i).x<xmin || input.get(i).y>ymax || input.get(i).y<ymin)
            outbound = true;
    }
    //System.out.println(outbound);
    if (outbound == true){
        for (int i = 0; i< input.size(); i++){
            Vector3 p1 = input.get(i);
            Vector3 p2 = input.get((i + 1) % input.size());
            if (p1.x<=xmax && p1.x>=xmin && p1.y<=ymax && p1.y>=ymin){
                if (p2.x<=xmax && p2.x>=xmin && p2.y<=ymax && p2.y>=ymin)  //p1,p2 inbound
                    output.add(p2);
                else{   //p1 inbound, p2 outbound, add intersection point
                    Vector3 L1 = findIntersection(p1.x, p1.y, p2.x, p2.y, xmin, ymin, xmax, ymin); 
                    Vector3 L2 = findIntersection(p1.x, p1.y, p2.x, p2.y, xmax, ymin, xmax, ymax); 
                    Vector3 L3 = findIntersection(p1.x, p1.y, p2.x, p2.y, xmax, ymax, xmin, ymax); 
                    Vector3 L4 = findIntersection(p1.x, p1.y, p2.x, p2.y, xmin, ymax, xmin, ymin);
                    //System.out.println(L2);
                    if (L1 != null)
                        output.add(L1);
                    else if (L2 != null)
                        output.add(L2);
                    else if (L3 != null)
                        output.add(L3);
                    else if (L4 != null)
                        output.add(L4);
                }
            }
            else{
                if (p2.x<=xmax && p2.x>=xmin && p2.y<=ymax && p2.y>=ymin){  //p1 outbound,p2 inbound, add intersection point and p2
                    Vector3 L1 = findIntersection(p1.x, p1.y, p2.x, p2.y, xmin, ymin, xmax, ymin); 
                    Vector3 L2 = findIntersection(p1.x, p1.y, p2.x, p2.y, xmax, ymin, xmax, ymax); 
                    Vector3 L3 = findIntersection(p1.x, p1.y, p2.x, p2.y, xmax, ymax, xmin, ymax); 
                    Vector3 L4 = findIntersection(p1.x, p1.y, p2.x, p2.y, xmin, ymax, xmin, ymin);
                    //System.out.println(L2);

                    if (L1 != null)
                        output.add(L1);
                    else if (L2 != null)
                        output.add(L2);
                    else if (L3 != null)
                        output.add(L3);
                    else if (L4 != null)
                        output.add(L4);
                    output.add(p2);
                    
                }
            }
        }
    }
    else{
        for (int i = 0; i< input.size(); i++){ //if any point inbound
            Vector3 p1 = input.get(i);
            output.add(p1);
        }
        
    }
    
    System.out.println(output);

    Vector3[] result = new Vector3[output.size()];
    for (int i = 0; i < result.length; i += 1) {
        result[i] = output.get(i);
    }
    return result;
}

public float getDepth(float x, float y, Vector3[] vertex) {
    // TODO HW3
    // You need to calculate the depth (z) in the triangle (vertex) based on the
    // positions x and y. and return the z value;
    Vector3 edge1 = vertex[1].sub(vertex[0]); // vertex[1] - vertex[0]
    Vector3 edge2 = vertex[2].sub(vertex[0]); // vertex[2] - vertex[0]

    // 計算法向量
    Vector3 normal = Vector3.cross(edge1, edge2);

    // ax+by+cz+d=0 的 a, b, c
    float a = normal.x;
    float b = normal.y;
    float c = normal.z;

    // d
    float d = -(a * vertex[0].x + b * vertex[0].y + c * vertex[0].z);

    // check c != 0
    if (Math.abs(c) < 1e-6) {
        return Float.POSITIVE_INFINITY; // 返回無窮大，表示無法計算深度
    }

    // caculated z
    float z = -(a * x + b * y + d) / c;
    //System.out.println(z);

    return z;

    //return 0.0;
}

float[] barycentric(Vector3 P, Vector4[] verts) {

    Vector3 A = verts[0].homogenized();
    Vector3 B = verts[1].homogenized();
    Vector3 C = verts[2].homogenized();

    // TODO HW4
    // Calculate the barycentric coordinates of point P in the triangle verts using
    // the barycentric coordinate system.

    float[] result = { 0.0, 0.0, 0.0 };

    return result;
}
