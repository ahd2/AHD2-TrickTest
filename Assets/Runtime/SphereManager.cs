using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SphereManager: MonoBehaviour
{
    public static float MaxImpactDistance;//最大影响距离
    public static float MaxImpactIntensity;//位移影响强度
    [SerializeField]
    private float _maxImpactDistance = 3.0f;//最大影响距离
    [SerializeField]
    private float _maxImpactIntensity = 0.5f;//位移影响强度

    void Update()
    {
        MaxImpactIntensity = _maxImpactIntensity;
        MaxImpactDistance = _maxImpactDistance;
    }
}
