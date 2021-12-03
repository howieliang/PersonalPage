public class BiLinearInterpolator
{
  private float a1, a2, a3, a4;

  public void updateCoefficients (float[][] p) {
    a1 = p[0][0];
    a2 = p[1][0]-p[0][0];
    a3 = p[0][1]-p[0][0];
    a4 = p[0][0]-p[1][0]-p[0][1]+p[1][1];
  }

  public float getValue (float x, float y) {
    return a1+x*a2+y*a3+x*y*a4;
  }
}
