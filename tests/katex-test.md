# KaTeX Backslash Fix Test Cases

## Test Case 1: The Reported Issue (cases environment)

This is the original bug report from issue #352:

$$
\begin{cases}
r_{i,k} &=& \Phi_i + (k-1)T_i \\
d_{i,k} &=& r_{i,k} + D_i
\end{cases}
$$

**Expected:** Should render as proper LaTeX cases environment with aligned equations.

---

## Test Case 2: Inline Math

This is inline math: $\alpha + \beta = \gamma$ and this is more: $\sqrt{x^2 + y^2}$

**Expected:** Should render inline with Greek letters and square root.

---

## Test Case 3: Multiple Backslash Scenarios (align environment)

$$
\begin{align}
x &= y \\
  &= z \\
  &= \sqrt{a + b}
\end{align}
$$

**Expected:** Multi-line aligned equations with line breaks.

---

## Test Case 4: Mixed Content

# Heading with <special> & "characters"

Some text with `code` and **bold**.

$$
\frac{d}{dx} \int_a^b f(x)dx
$$

```python
def hello():
    return "world"
```

**Expected:** All elements render correctly - heading with special chars, code, bold, LaTeX, and syntax-highlighted code.

---

## Test Case 5: Edge Cases (literal backslashes and braces)

$$
\text{Backslashes: \\, braces: \{, \}}
$$

**Expected:** Literal backslashes and braces render in LaTeX text mode.

---

## Test Case 6: Complex LaTeX Commands

$$
\begin{bmatrix}
a_{11} & a_{12} & \cdots & a_{1n} \\
a_{21} & a_{22} & \cdots & a_{2n} \\
\vdots & \vdots & \ddots & \vdots \\
a_{m1} & a_{m2} & \cdots & a_{mn}
\end{bmatrix}
$$

**Expected:** Matrix with proper alignment and dots.

---

## Test Case 7: Multiple Math Blocks

First equation:
$$
E = mc^2
$$

Second equation:
$$
\nabla \times \vec{E} = -\frac{\partial \vec{B}}{\partial t}
$$

**Expected:** Both equations render correctly with different symbols.

---

## Test Case 8: Nested Environments

$$
\begin{equation}
\begin{split}
f(x) &= \sum_{n=0}^{\infty} \frac{f^{(n)}(a)}{n!}(x-a)^n \\
     &= f(a) + f'(a)(x-a) + \frac{f''(a)}{2!}(x-a)^2 + \cdots
\end{split}
\end{equation}
$$

**Expected:** Nested environments render correctly with Taylor series.

---

## Test Case 9: Special Characters in Regular Text

This text contains special HTML characters: `<div>`, `&nbsp;`, `"quotes"`, and `'apostrophes'`.

These should be preserved in regular markdown but not interfere with LaTeX.

**Expected:** Special characters display correctly in text, LaTeX still works.

---

## Test Case 10: Mixed Inline and Block Math

The quadratic formula $ax^2 + bx + c = 0$ has solutions:

$$
x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
$$

where $\Delta = b^2 - 4ac$ is the discriminant.

**Expected:** Inline and block math both render correctly in the same paragraph.
