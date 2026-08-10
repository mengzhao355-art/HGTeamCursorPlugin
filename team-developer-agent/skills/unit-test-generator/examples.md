# unit-test-generator 示例

生成时对齐：命名清晰、Arrange-Act-Assert、有意义断言。具体类型名、命名空间、框架以仓库现有测试为准。

## 用例表 → 测试方法

| Method | Scenario | Expected |
|--------|----------|----------|
| Parse | ValidInput | ReturnsValue |
| Parse | EmptyInput | ReturnsFalseOrDefault |
| Parse | GarbageThenValid | IgnoresPrefixAndSucceeds |

对应方法名（默认约定）：

```csharp
Parse_ValidInput_ReturnsValue
Parse_EmptyInput_ReturnsFalseOrDefault
Parse_GarbageThenValid_IgnoresPrefixAndSucceeds
```

## 结构模板（xUnit）

```csharp
using Xunit;

namespace {ExistingTestsNamespace};

public class {TargetClass}Tests
{
    [Fact]
    public void {Method}_{Scenario}_{ExpectedOutcome}()
    {
        // Arrange
        var input = /* ... */;

        // Act
        var result = {TargetClass}.{Method}(input);

        // Assert
        Assert.True(result.Success);
        Assert.Equal(expected, result.Value);
    }

    [Theory]
    [InlineData("")]
    [InlineData("   ")]
    public void {Method}_BlankInput_Fails(string input)
    {
        var result = {TargetClass}.{Method}(input);
        Assert.False(result.Success);
    }
}
```

## 边界场景写法提示

- **分步输入**（半包/增量）：第一次调用后断言“尚未完成”，补齐后再断言成功。
- **超限/非法**：断言拒绝、清空或安全回退，而非抛未声明异常（除非契约就是抛）。
- **已完成的 Task/TCS**：可直接读结果；测**未完成**异步 API 时用 `await`，禁止 `.Wait()` / `.Result` 阻塞。

## 反例（禁止）

```csharp
// ❌ 无意义断言
Assert.True(true);

// ❌ 测外部设备/连接本身，而非可隔离逻辑
[Fact]
public void OpenDevice_Succeeds() { /* ... */ }

// ❌ 阻塞异步
sut.DoAsync().Wait();
```
