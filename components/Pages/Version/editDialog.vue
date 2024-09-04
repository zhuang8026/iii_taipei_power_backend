<template>
  <el-dialog v-loading="loading" title="編輯版本資訊" :visible.sync="show" :before-close="reset">
    <el-form :model="ruleForm" :rules="rules" ref="ruleForm">
      <el-form-item prop="description">
        <el-input
          type="textarea"
          :rows="10"
          v-model="ruleForm.description"
          resize="none"
          placeholder="請輸入資訊內容"
        />
      </el-form-item>
    </el-form>
    <span slot="footer" class="dialog-footer">
      <el-button @click="editVersionInfo">送出</el-button>
    </span>
  </el-dialog>
</template>

<script>
import backendApi from '@/assets/js/api/backendApi.js';

export default {
  props: {
    value: {
      type: Boolean,
      default: false,
    },
    editData: {
      type: Object,
      default: () => {},
    },
  },
  data() {
    return {
      show: false,
      loading: false,
      ruleForm: {
        description: '',
      },
      rules: {
        description: [
          {
            required: true,
            message: '請選擇資訊內容',
            trigger: 'blur',
          },
        ],
      },
    };
  },
  watch: {
    value(val) {
      const vm = this;
      vm.show = val;
    },
    show(val) {
      const vm = this;
      vm.$emit('input', val);
    },
    editData: {
      handler() {
        const vm = this;
        vm.ruleForm.description = vm.editData.descriptionList?.join('\n');
      },
    },
  },
  methods: {
    reset() {
      const vm = this;
      vm.resetForm('ruleForm');
      vm.show = false;
    },
    validate(formName) {
      const vm = this;
      vm.$refs[formName].validate((valid) => {
        if (valid) {
          vm.addVersionInfo();
        }
      });
    },
    async editVersionInfo() {
      const vm = this;
      vm.loading = true;
      const obj = {
        description: vm.ruleForm.description,
        date: vm.editData.reportTime,
      };
      const res = await backendApi.editVersionInfo(obj);
      if (res.code === 200) {
        vm.$emit('success', 'edit');
        vm.reset();
      }
      vm.loading = false;
    },
    resetForm(formName) {
      const vm = this;
      vm.$refs[formName].resetFields();
    },
  },
};
</script>
