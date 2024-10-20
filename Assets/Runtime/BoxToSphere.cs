using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BoxToSphere : MonoBehaviour
{
    static int baseColorId = Shader.PropertyToID("_SphereCol");

    [SerializeField]
    Mesh mesh = default;

    [SerializeField]
    Material material = default;
    Matrix4x4[] matrices = new Matrix4x4[1023];
    Vector4[] baseColors = new Vector4[1023];
    float[] sphereParams = new float[1023];

    MaterialPropertyBlock block;

    private float _sphereRadius;
    
    void Awake () {
        for (int i = 0; i < matrices.Length; i++)
        {
            Vector3 pos = Random.insideUnitSphere * 10f;
            matrices[i] = Matrix4x4.TRS(
                pos, Quaternion.identity, Vector3.one * 0.3f
            );
            baseColors[i] =
                new Vector4(Random.value, Random.value, 1f, 1f);
            sphereParams[i] = SphereSDF(pos);
        }
    }
    void Update () {
        if (block == null) {
            block = new MaterialPropertyBlock();
            block.SetVectorArray(baseColorId, baseColors);
        }
        Graphics.DrawMeshInstanced(mesh, 0, material, matrices, 1023, block);
    }

    float SphereSDF(Vector3 pos)
    {
        return pos.magnitude - _sphereRadius;//默认为球心在原点
    }
}
